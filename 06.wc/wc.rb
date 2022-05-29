#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'debug'
require 'readline'

AJUST_SPACE = 4

def main
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |v| options[:l] = v }
  file_names = opt.parse!(ARGV)

  texts = []
  if file_names.empty?
    texts << $stdin.readlines.join
  else
    file_names.each do |v|
      texts << File.read(v)
    end
  end

  run_wc(file_names, texts, options)
end

  def run_wc(file_names, texts, options)
  items =
    texts.map.with_index do |text, i|
      {
        line_counts: text.count("\n"),
        word_counts: text.split(' ').size,
        byte_counts: text.size,
        file_names: file_names[i]
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

  if options[:l]
    display_l_option(items, total_line_count)
  else
    display_normal(items, total_line_count, total_word_count, total_byte_count)
  end
end

def display_normal(items, total_line_count, total_word_count, total_byte_count)
  items.each do |item|
    puts "    #{item[:line_counts].to_s.rjust(AJUST_SPACE)}    #{item[:word_counts].to_s.rjust(AJUST_SPACE)}    #{item[:byte_counts].to_s.rjust(AJUST_SPACE)} #{item[:file_names]}"
  end
  return unless items.size >= 2

  puts "    #{total_line_count.to_s.rjust(AJUST_SPACE)}    #{total_word_count.to_s.rjust(AJUST_SPACE)}    #{total_byte_count.to_s.rjust(AJUST_SPACE)} total"
end

def display_l_option(items, total_line_count)
  items.each do |item|
    puts "    #{item[:line_counts].to_s.rjust(AJUST_SPACE)} #{item[:file_names]}"
  end
  return unless items.size >= 2

  puts "    #{total_line_count} total"
end

def display_stdin_l_option(line_count)
  puts "       #{line_count} "
end

def display_stdin(line_count, word_count, byte_count)
  p "標準入力"
  puts "      #{line_count}       #{word_count}      #{byte_count}"
end

main
