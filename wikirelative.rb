#!/usr/bin/env ruby

# add local files to load path
$:.unshift File.dirname(__FILE__)

require 'lib/unique_queue'
require 'open-uri'
require 'nokogiri'

if ARGV[0].empty? || ARGV[1].empty?
  puts "You didn't pass any arguments"
  exit 1
end

start = ARGV[0]
destination = ARGV[1]

BASE_URL = "https://en.wikipedia.org"

# to check the arguments
WIKI_REGEXP = Regexp.new(Regexp.escape("https://en.wikipedia.org"))

# to check links on a wikipedia page
WIKI_PAGE_REGEXP = /\A\/wiki\/[-\w,#%!§$&()]+\z/

# we have to escape the string before initializing it because there will be conflicts with "." or "/"
DESTINATION_REGEX = Regexp.new(Regexp.escape(destination))

# visited links array
VISITED = []

# next links array
LINK_QUEUE = []

unless WIKI_REGEXP =~ start && WIKI_REGEXP =~ destination 
  puts "You didn't pass wikipedia links as arguments. NOTE: It has to be the english wikipedia."
  exit 1
end

# startup stuff
LINK_QUEUE << start
steps = 0
beginning_time = Time.now

while !LINK_QUEUE.empty?
  
  # next element from queue
  next_link = LINK_QUEUE.shift
  
  # add base url if it does not exist there yet
  next_link = "#{BASE_URL}#{next_link}" unless next_link.start_with?(BASE_URL)
  
  if DESTINATION_REGEX =~ next_link
    puts "FOUND! #{next_link}"
    puts "Needed steps: #{steps}"
    puts "Needed time: #{(Time.now - beginning_time)}"
    exit 0
  end
  
  # only use links in body with href
  puts "Checking #{next_link}"
  
  begin
    links = Nokogiri::HTML(open("#{next_link}")).css('body a[href^="/wiki/"]')
    
    # push all links in queue if they have not been visited, the regexp fits and the element is not in the queue yet
    links.each do |link|
      LINK_QUEUE.unique_push(link['href']) if !(VISITED.include? link['href']) && WIKI_PAGE_REGEXP =~ link['href']
    end
    
    steps = steps + 1
  rescue
    puts "#{next_link} was unreachable. Seems like this wiki page is down"
  end
end

puts "Found no way :("
puts "Tries: #{steps}"
puts "Time spent searching: #{(Time.now - beginning_time)}"
