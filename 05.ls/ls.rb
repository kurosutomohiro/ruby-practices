#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'
require 'debug'

PERMISSION = {
  0 => '---',
  1 => '--x',
  2 => '-w-',
  3 => '-wx',
  4 => 'r--',
  5 => 'r-x',
  6 => 'rx-',
  7 => 'rwx'
}.freeze

FILE_TYPE = {
  'fifo' => 'p',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'blockSpecial' => 'b',
  'file' => '-',
  'link' => 'l',
  'socket' => 's'
}.freeze

def main
  params = ARGV.getopts('a', 'r', 'l')
  current_dir_items = Dir.glob('*')

  if params['a']
    current_dir_items = Dir.glob('*', File::FNM_DOTMATCH)
  end

  if params['r']
    current_dir_items = current_dir_items.reverse
  end

  if params['l']
    format_l_option(current_dir_items)
  else
    format(current_dir_items)
  end
end

def format(current_dir_items)
  columun_count = 3
  current_dir_items << ' ' until (current_dir_items.size % columun_count).zero?

  # 1列に格納するファイル数
  row = (current_dir_items.size / columun_count).ceil

  # current_dir_itemsの中で、最も大きいファイルサイズ＋固定で追加するスペース数を格納
  fixed_space_size = 7
  max_space_size = current_dir_items.max_by(&:length).length + fixed_space_size

  # 左揃えにするため、各要素に空白を追加
  space_added_items =
    current_dir_items.map do |items|
      each_space_size = max_space_size - items.size
      items + ' ' * each_space_size
    end

  transposed_items = space_added_items.each_slice(row).to_a.transpose

  display(transposed_items)
end

# lオプション用の整形メソッド
def format_l_option(current_dir_items)
  total_block = current_dir_items.sum { |v| File.lstat(v).blocks }

  files_l_option =
    current_dir_items.map do |current_dir_item|
      lstat = File.lstat(current_dir_item)
      {
        permission: format_permission(current_dir_item),
        n_link: lstat.nlink,
        owner: Etc.getpwuid(lstat.uid).name,
        group: Etc.getgrgid(lstat.gid).name,
        size: File.lstat(current_dir_item).size.to_s.rjust(5),
        time_stamp: format_time_stamp(lstat),
        name: File.basename(current_dir_item)
      }
    end

  display_l_option(total_block, files_l_option)
end

def format_permission(current_dir_item)
  stat = File.lstat(current_dir_item)
  file_stat_mode = stat.mode.to_s(8)

  ftype = FILE_TYPE[stat.ftype]
  permission_owner = PERMISSION[file_stat_mode[-3].to_i]
  permission_group = PERMISSION[file_stat_mode[-2].to_i]
  permission_user = PERMISSION[file_stat_mode[-1].to_i]

  "#{ftype}#{permission_owner}#{permission_group}#{permission_user}"
end

def format_time_stamp(lstat)
  half_year_ago = Date.today.prev_month(6).to_time

  if lstat.mtime < half_year_ago
    lstat.mtime.strftime('%_m %e %_5Y')
  else
    lstat.mtime.strftime('%_m %e %H:%M')
  end
end

def display_l_option(total_block, files_l_option)
  puts "total #{total_block}"

  files_l_option.each do |v|
    puts "#{v[:permission]}  #{v[:n_link]} #{v[:owner]}  #{v[:group]} #{v[:size]} #{v[:time_stamp]} #{v[:name]}"
  end
end

def display(transposed_items)
  transposed_items.each do |items|
    puts items.join('')
  end
end

main
