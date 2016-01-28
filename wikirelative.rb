#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

if ARGV[0].empty? || ARGV[1].empty?
  puts "You didn't pass any arguments"
  exit 1
end

start = ARGV[0]
destination = ARGV[1]

WIKI_REGEX = /.*wikipedia\..*/
DESTINATION_REGEX = Regexp.new(Regexp.escape(destination))

unless WIKI_REGEX =~ start && WIKI_REGEX =~ destination 
  puts "You didn't pass wikipedia links as arguments"
  exit 1
end
