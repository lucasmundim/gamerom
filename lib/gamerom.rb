# frozen_string_literal: true

require_relative 'gamerom/config'
require_relative 'gamerom/game'
require_relative 'gamerom/game_info'
require_relative 'gamerom/repo'
require_relative 'gamerom/cli'
require_relative 'gamerom/version'

module Gamerom
  class Error < StandardError; end
end
