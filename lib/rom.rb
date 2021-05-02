# frozen_string_literal: true

require_relative "rom/config"
require_relative "rom/game"
require_relative "rom/platform"
require_relative "rom/cli"
require_relative "rom/version"

module Rom
  class Error < StandardError; end
end
