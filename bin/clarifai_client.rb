#!/usr/bin/env ruby
# encoding: utf-8
require 'json'
require 'pp'
require 'fileutils'
require_relative "smile_getter.rb"

GLASSES = "ai_mCpQg89c"
DRINK = "ai_zJx6RbxW"
BEER = "ai_TBlp0Pt3"
TOKEN = 'Please set your token :)'
HELLO_PATTERN = 2

def score(images)
  param = images.map{|img| %Q{-F "encoded_data=@#{img}"}}.join(" ")
  json = `curl -s -H "Authorization: Bearer #{TOKEN}" #{param} https://api.clarifai.com/v1/tag/`

  response = JSON.parse(json)

  tag = response["results"][0]["result"]["tag"]
  ids = tag["concept_ids"]
  classes = tag["classes"]
  probs = tag["probs"]

  keyAry = ids
  keyValue = classes
  ary = [keyAry,keyValue].transpose
  id_map = Hash[*ary.flatten]

  keyAry = ids
  keyValue = probs
  ary = [keyAry,keyValue].transpose
  probs_map = Hash[*ary.flatten]

  keyAry = classes
  keyValue = probs
  ary = [keyAry,keyValue].transpose
  classes_map = Hash[*ary.flatten]

  file_name = []
  file_name << "b#{probs_map[BEER] || 0}"
  file_name << "g#{probs_map[GLASSES] || 0}"
  file_name << "d#{probs_map[DRINK] || 0}"
  name = file_name.join("_")
  puts images.shift, name

  return probs_map[BEER].nil?
end

def run
  split_dir = File.expand_path("#{File.dirname(__FILE__)}/../data/image_getter/split")
  trash_dir = File.join(split_dir, "trash")
  FileUtils.mkdir_p(trash_dir)
  loop do
    Dir.foreach(split_dir) do |f|
      next if f =~ /^\./ || f == 'trash'
      image_dir = File.join(split_dir, f)
      # next if Dir.entries(image_dir).size < 6
      next if Dir.entries(image_dir).size < 4
      count = 0
      smile_getter_flg = rand(10) >= 6
      smile_count = 0
      Dir.foreach(image_dir) do |image_path|
        puts "Start clarifai : #{Time.now}"
        next if image_path =~ /^\./
        abs_image_path = File.join(image_dir, image_path)
        count += 1 if score([abs_image_path])
        if smile_getter_flg && SmileGetter.score([abs_image_path])
          smile_count += 1
          `open #{abs_image_path}`
        end
      end
      #count = 0
      if count > 0
        puts "beer_tsuika #{count}"
        `#{File.dirname(__FILE__)}/kakegoe.sh bell`
        # `say "すいませぇん、ビール、追加で"`
        `#{File.dirname(__FILE__)}/kakegoe.sh beer_tsuika#{count}`
      elsif smile_getter_flg && smile_count >= 1
        puts 'smile'
        `#{File.dirname(__FILE__)}/kakegoe.sh smile`
      else
        puts 'random'
        `#{File.dirname(__FILE__)}/kakegoe.sh hello#{rand(HELLO_PATTERN)}`
      end
      FileUtils.move(image_dir, trash_dir)
      puts "End clarifai : #{Time.now}"
    end
  end
end

run
#exit if ARGV.size == 0
#
#puts score(ARGV)

__END__
parent = "img/full"
Dir.foreach(parent) do |f|
    next if f =~ /^\./
    from_file = "#{parent}/#{f}"
    ext = File.extname(from_file)
    score = score([from_file])
    to_file = "#{parent}/#{score}#{ext}"
    File.rename(from_file, to_file)
end
