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

  if file_names.empty?
    wc_from_stdin(options)
  else
    wc_with_file_name(file_names, options)
  end
end

# 標準入力用のメソッド
def wc_from_stdin(options)
  input = $stdin.readlines
  line_count = input.size

  if options[:l]
    display_stdin_l_option(line_count)
  else
    word_count = input.each.sum { |v| v.split(' ').size }
    byte_count = input.each.sum(&:bytesize)
    display_stdin(line_count, word_count, byte_count) 
  end
end

# 標準入力でないメソッド
def wc_with_file_name(file_names, options)
  texts = []
  file_names.each do |v|
    texts << File.read(v)
  end

  items =
    texts.map.with_index do |text, i|
      {
      line_counts: text.count("\n"),
      word_counts: text.split(' ').size,
      byte_counts: text.size,
      file_names: file_names[i],
      }
    end

  total_line_count = 0
  total_word_count = 0
  total_byte_count = 0
  items.each do |v|
    total_line_count += v[:line_counts]
    total_word_count += v[:word_counts]
    total_byte_count += v[:byte_counts]
  end

  if options[:l]
    display_l_option(items, total_line_count)
  else
    display_normal(items, file_names, total_line_count, total_word_count, total_byte_count)
  end
end

def calc_line_count(text, file_names)
  line_count = text.count("\n")
end

def display_normal(items, file_names, total_line_count, total_word_count, total_byte_count)
  items.each.with_index do |v, i|
  puts "    #{v[:line_counts].to_s.rjust(AJUST_SPACE)}    #{v[:word_counts].to_s.rjust(AJUST_SPACE)}    #{v[:byte_counts].to_s.rjust(AJUST_SPACE)} #{v[:file_names]}"
  end
  if file_names.size >= 2
    puts "    #{total_line_count.to_s.rjust(AJUST_SPACE)}      #{total_word_count}     #{total_byte_count} total"
  end
end

def display_l_option(items, total_line_count)
  items.each do |item|
    puts "    #{item[:line_count]} #{item[:file]}"
  end
  return unless items.size >= 2

  puts "    #{total_line_count} total"
end

def display_stdin_l_option(line_count)
  puts "       #{line_count} "
end

def display_stdin(line_count, word_count, byte_count)
  puts "      #{line_count}       #{word_count}      #{byte_count}"
end

main