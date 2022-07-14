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
      file_names.map do |file_name|
        { name: file_name, contents: File.read(file_name) }
      end
    end

  calculated_items = calc_wc(file_name_and_contents)
  display(calculated_items, options)
end

def calc_wc(file_name_and_contents)
  total = { line_count: 0, word_count: 0, byte_count: 0, file_name: 'total' }
  items = []

  file_name_and_contents.each do |file_name_and_content|
    file_content = file_name_and_content[:contents]
    item =
      {
        line_count: file_content.count("\n"),
        word_count: file_content.split(' ').size,
        byte_count: file_content.size,
        file_name: file_name_and_content[:name]
      }
    items << item
    total[:line_count] += item[:line_count]
    total[:byte_count] += item[:byte_count]
    total[:word_count] += item[:word_count]
  end

  items << total if file_name_and_contents.size >= 2

  items
end

def format_value(value)
  value.to_s.rjust(ADJUST_SPACE_SIZE)
end

def create_row(calculated_item, options)
  result = []
  if options[:l] || options.empty?
    result << format_value(calculated_item[:line_count])
  end

  if options[:w] || options.empty?
    result << format_value(calculated_item[:word_count])
  end

  if options[:c] || options.empty?
    result << format_value(calculated_item[:byte_count])
  end

  [*result, " #{calculated_item[:file_name]}"].join
end

def display(calculated_items, options)
  calculated_items.each do |calculated_item|
    puts create_row(calculated_item, options)
  end
end

main
