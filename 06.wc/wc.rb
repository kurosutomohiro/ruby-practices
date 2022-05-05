#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'debug'
require 'readline'

def main
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |v| options[:l] = v }
  file_names = opt.parse!(ARGV)

  if file_names.any? && options[:l]
    format_l_option(file_names)
  elsif file_names.any? && options.empty?
    format_normal(file_names)
  # ファイル指定なし、lオプション
  elsif file_names.empty? && options[:l]
    input = $stdin.readlines
    format_stdin_l_option(input)
  # ファイル指定なし、オプションなし
  elsif file_names.empty? && options.empty?
    input = $stdin.readlines
    format_stdin(input)
  end
end

def format_normal(file_names)
  total_line_count = file_names.sum { |file_name| File.read(file_name).count("\n") }.to_s.rjust(4)
  total_word_cout = file_names.sum { |file_name| File.read(file_name).split(/\s+/).count }.to_s.rjust(4)
  total_byte_count = file_names.sum { |file_name| File.size(file_name) }.to_s.rjust(4)
  
  items =
    file_names.map do |file_name| {
      line_count: File.read(file_name).count("\n").to_s.rjust(4),
      word_count: File.read(file_name).split(/\s+/).count.to_s.rjust(4),
      byte_count: File.size(file_name).to_s.rjust(4),
      file: file_name
      }
    end
  display_normal(items, total_line_count, total_word_cout, total_byte_count)
end

def display_normal(items, total_line_count, total_word_cout, total_byte_count)
  items.each do |item|
    puts "    #{item[:line_count]}    #{item[:word_count]}    #{item[:byte_count]} #{item[:file]}"
  end
  if items.size >= 2
    puts "    #{total_line_count}    #{total_word_cout}    #{total_byte_count} total"
  end
end

def format_l_option(file_names)
  total_line_count = file_names.sum { |file_name| File.read(file_name).count("\n") }.to_s.rjust(4)
  items =
    file_names.map do |file_name| {
      line_count: File.open(file_name).read.count("\n").to_s.rjust(4),
      file: file_name
    }
  end
  display_l_option(items, total_line_count)
end

def display_l_option(items, total_line_count)
  items.each do |item|
    puts "    #{item[:line_count]} #{item[:file]}"
  end
  if items.size >= 2
    puts "    #{total_line_count} total"
  end
end

def format_stdin_l_option(input)
  line_count = input.size
  display_stdin_l_option(line_count)
end

def display_stdin_l_option(line_count)
  puts "       #{line_count} "
end

def format_stdin(input)
  line_count = input.size
  word_count = input.each.sum { |v| v.split(' ').size }
  byte_count = input.each.sum { |v| v.bytesize }
  display_stdin(line_count, word_count, byte_count)
end

def display_stdin(line_count, word_count, byte_count)
  puts "      #{line_count}       #{word_count}      #{byte_count}"
end

main
