# frozen_string_literal: true

require 'thor'

module Rom
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc 'version', 'Print program version'
    def version
      puts Rom::VERSION
    end
  end
end
