# frozen_string_literal: true

require 'fileutils'
require 'logger'
require 'rest-client'
require 'mechanize'

module Gamerom
  ROM_ROOT = ENV['ROM_ROOT'] || File.expand_path('~/.gamerom')
  CACHE_DIR = ENV['CACHE_DIR'] || "#{ROM_ROOT}/cache"
  GAME_DIR = ENV['GAME_DIR'] || "#{ROM_ROOT}/games"
  LOG_DIR = ENV['LOG_DIR'] || "#{ROM_ROOT}/logs"
  STATE_DIR = ENV['STATE_DIR'] || "#{ROM_ROOT}/state"
end

FileUtils.mkdir_p(Gamerom::LOG_DIR)
logger = Logger.new("#{Gamerom::LOG_DIR}/requests.log")
RestClient.log = logger
Mechanize.log = logger
