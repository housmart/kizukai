#!/usr/bin/env ruby
#
# This script required ImageMagick.
#
require 'fileutils'

class ImageSplitter
  IMAGE_STOCK_DIR = File.expand_path('../../data/image_getter', __FILE__)
  IMAGE_SPLIT_DIR = "#{IMAGE_STOCK_DIR}/split".freeze
  IMAGE_TRASH_DIR = "#{IMAGE_STOCK_DIR}/trash".freeze

  p IMAGE_STOCK_DIR
  p IMAGE_TRASH_DIR

  def self.run
    loop do
      split
      sleep 1
    end
  end

  private

  def self.split
    FileUtils.mkdir_p IMAGE_SPLIT_DIR
    FileUtils.mkdir_p IMAGE_TRASH_DIR
    image_names = Dir.entries(IMAGE_STOCK_DIR.to_s).select { |f| f =~ /.+.jpg/ }
    p image_names

    image_names.each do |image_name|
      p image_name
      image_dir = image_name.split('.').first
      image_dir_path = "#{IMAGE_SPLIT_DIR}/#{image_dir}"
      FileUtils.mkdir_p image_dir_path
      image_path = "#{IMAGE_STOCK_DIR}/#{image_name}"
      `convert #{image_path} -modulate 100,200,100 #{image_path}`
      # `convert -crop 25%x100% #{image_path} #{image_dir_path}/#{image_name}`
      `convert -crop 50%x100% #{image_path} #{image_dir_path}/#{image_name}`
      FileUtils.mv image_path, IMAGE_TRASH_DIR.to_s
    end
  end
end

ImageSplitter.run
