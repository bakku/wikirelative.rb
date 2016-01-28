#!/usr/bin/env ruby

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

unless WIKI_REGEXP =~ start && WIKI_REGEXP =~ destination 
  puts "You didn't pass wikipedia links as arguments. NOTE: It has to be the english wikipedia."
  exit 1
end

# startup stuff
next_link = start
steps = 0
beginning_time = Time.now

while !next_link.empty?
  if DESTINATION_REGEX =~ next_link
    puts "FOUND! #{next_link}"
    puts "Needed steps: #{steps}"
    puts "Needed time: #{(Time.now - beginning_time)}"
    exit 0
  end
  
  # only use links in body with href
  puts "Checking #{next_link}"
  links = Nokogiri::HTML(open("#{next_link}")).css('body a[href^="/wiki/"]')
  
  # reset
  next_link = ""
  
  # determine link
  links.each do |link|
    # already visited?
    if VISITED.include? link['href']
      next
      
    # is it a wiki site defined as in the whitelist ?
    elsif WIKI_PAGE_REGEXP =~ link['href']
      next_link = link['href']
      VISITED << next_link
      next_link = "#{BASE_URL}#{next_link}"

      # check if link works. if not choose next one      
      begin
        open(next_link)
        
        # increment steps
        steps = steps + 1
        
        # link worked. proceed with this link
        break
      rescue
        next
      end
    end
  end
end

puts "Found no way :("


