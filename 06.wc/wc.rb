#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'debug'
require 'readline'

ADJUST_SPACE_SIZE = 8

def main
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |v| options[:l] = v }
  file_names = opt.parse!(ARGV)

  texts = 
  if file_names.empty?
    [{file_name: '', file_contents: $stdin.readlines.join}]
  else
    file_names.map do |v|
      {file_name: v, file_contents: File.read(v)}
    end
  end

  calc(file_names, texts, options)
end

def calc(file_names, texts, options)
  items =
    texts.map do |text|
      {
        line_counts: text[:file_contents].count("\n"),
        word_counts: text[:file_contents].split(' ').size,
        byte_counts: text[:file_contents].size
      }
    end

  total_line_count = 0
  total_word_count = 0
  total_byte_count = 0
  items.each do |item|
    total_line_count += item[:line_counts]
    total_word_count += item[:word_counts]
    total_byte_count += item[:byte_counts]
  end
  format(items, options, total_line_count, total_word_count, total_byte_count)
end

def format(items, options, total_line_count, total_word_count, total_byte_count)
  formatted_items = items.map do |v|
    {
      line_counts: v[:line_counts].to_s.rjust(ADJUST_SPACE_SIZE, ' '),
      word_counts: v[:word_counts].to_s.rjust(ADJUST_SPACE_SIZE, ' '),
      byte_counts: v[:byte_counts].to_s.rjust(ADJUST_SPACE_SIZE, ' '),
      file_names: v[:file_names]
    }
  end

  total_line_count = total_line_count.to_s.rjust(ADJUST_SPACE_SIZE, ' ')
  total_word_count = total_word_count.to_s.rjust(ADJUST_SPACE_SIZE, ' ')
  total_byte_count = total_byte_count.to_s.rjust(ADJUST_SPACE_SIZE, ' ')

  display(formatted_items, options, total_line_count, total_word_count, total_byte_count)
end

def display(formatted_items, options, total_line_count, total_word_count, total_byte_count)
  formatted_items.each do |formatted_item|
    output = if options[:l]
               [formatted_item[:line_counts]]
             else
               [formatted_item[:line_counts], formatted_item[:word_counts], formatted_item[:byte_counts]]
             end
    puts output.join('') + " #{formatted_item[:file_names]}"
  end
  return unless formatted_items.size >= 2

  total = []
  if options[:l]
    total.push(total_line_count)
  else
    total.push(total_line_count, total_word_count, total_byte_count)
  end

  puts "#{total.join('')} total"
end

main
