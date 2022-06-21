#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
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

  calculated_items = calc(file_names, texts, options)
  formatted_items = format(calculated_items)
  
  display(formatted_items, options)
end

def calc(file_names, texts, options)
  items =
    texts.map.with_index do |text, i|
      {
        line_count: text[:file_contents].count("\n"),
        word_count: text[:file_contents].split(' ').size,
        byte_count: text[:file_contents].size,
        file_name: file_names[i]
      }
    end

  return items if items.size <= 1

  total_line_count = 0
  total_word_count = 0
  total_byte_count = 0
  items.each do |item|
    total_line_count += item[:line_count]
    total_word_count += item[:word_count]
    total_byte_count += item[:byte_count]
  end

  totals = {line_count: total_line_count, word_count: total_word_count, byte_count: total_byte_count, file_name: 'total'}
  items.push(totals)

  items
end

def format(calculated_items)
  formatted_items =
  calculated_items.map do |calculated_item|
    calculated_item.transform_values do |v|
    v.to_s.rjust(ADJUST_SPACE_SIZE, ' ')
    end
  end
end

def display(calculated_items, options)
  calculated_items.each do |calculated_item|
    calculated_item.each_value do |v|
    end
  end

  calculated_items.each do |calculated_item|
    if options[:l]
      puts "#{calculated_item[:line_count]}#{calculated_item[:file_name]}"
    else
      puts "#{calculated_item[:line_count]}#{calculated_item[:word_count]}#{calculated_item[:byte_count]}#{calculated_item[:file_name]}"
    end
  end
end

main
