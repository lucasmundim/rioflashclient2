#!/usr/bin/env ruby

require 'rvideo'

Dir["*.{flv,mp4}"].each do |filename|
  file = RVideo::Inspector.new(:file => filename)
  puts "File                     : #{filename}"
  puts "Container                : #{file.container}"
  puts "Video Codec              : #{file.video_codec}"
  puts "Audio Codec              : #{file.audio_codec}"
  puts "Bit Rate                 : #{file.bitrate}#{file.bitrate_units}"
  puts "Resolution               : #{file.resolution}"
  puts "Duration                 : #{file.duration}s (#{file.raw_duration})"
  puts "Video Color Space        : #{file.video_colorspace}"
  puts "Audio Sample Rate        : #{file.audio_sample_rate}#{file.audio_sample_units}"
  puts "Audio Channels           : #{file.audio_channels} #{file.audio_channels_string}"
  puts
  puts
end