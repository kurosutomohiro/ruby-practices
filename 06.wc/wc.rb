#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'readline'

ADJUST_SPACE_SIZE = 8

def main
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |v| options[:l] = v }
  opt.on('-w') { |v| options[:w] = v }
  opt.on('-c') { |v| options[:c] = v }
  file_names = opt.parse!(ARGV)

  file_name_and_contents =
    if file_names.empty?
      [{ name: '', contents: $stdin.readlines.join }]
    else
      file_names.map do |v|
        { name: v, contents: File.read(v) }
      end
    end

  calculated_items = calc_wc(file_name_and_contents)
  formatted_items = calculated_items.map do |calculated_item|
    add_space(calculated_item)
  end

  display(formatted_items, options)
end

def calc_wc(file_name_and_contents)
  total_line_count = 0
  total_word_count = 0
  total_byte_count = 0

  items = []
  file_name_and_contents.each_with_index do |file_name_and_content, i|
    items <<
      {
        line_count: file_name_and_content[:contents].count("\n"),
        word_count: file_name_and_content[:contents].split(' ').size,
        byte_count: file_name_and_content[:contents].size,
        file_name: file_name_and_content[:name]
      }
    total_line_count += items[i][:line_count]
    total_byte_count += items[i][:byte_count]
    total_word_count += items[i][:word_count]
  end
  return items if file_name_and_contents.size < 2

  items.push({ line_count: total_line_count, word_count: total_word_count, byte_count: total_byte_count, file_name: 'total' })
  items
end

def add_space(calculated_item)
  result = {}
  %i[line_count word_count byte_count file_name].each do |key|
    result.store(key, calculated_item[key].to_s.rjust(ADJUST_SPACE_SIZE))
  end
  result
end

def store_optionally_elements(formatted_item, options)
  result = []
  if options[:l]
    result << formatted_item[:line_count]
  end

  if options[:w]
    result << formatted_item[:word_count]
  end

  if options[:c]
    result << formatted_item[:byte_count]
  end

  if options.empty?
    result << formatted_item[:line_count]
    result << formatted_item[:word_count]
    result << formatted_item[:byte_count]
  end

  result << formatted_item[:file_name]
  result.join
end

def display(formatted_items, options)
  formatted_items.each do |formatted_item|
    puts store_optionally_elements(formatted_item, options)
  end
end

main
