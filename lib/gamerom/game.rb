# frozen_string_literal: true

require 'fileutils'
require 'ostruct'
require 'yaml'

module Gamerom
  # Game - Represents a game ROM
  class Game < OpenStruct
    def filenames
      YAML.load_file(state_filename).map do |filename|
        "#{filepath}/#{filename}"
      end
    end

    def filepath
      "#{Gamerom::GAME_DIR}/#{repo.name}/#{platform}/#{region}"
    end

    def install
      repo.install self do |filenames|
        update_state filenames
      end
    end

    def installed?
      File.exist? state_filename
    end

    def state_filename
      "#{Gamerom::STATE_DIR}/#{repo.name}/#{platform}/#{region}/#{id}"
    end

    def to_s
      install_status = ''
      install_status = " (#{shell.set_color "installed", :green})" if installed?
      tags = ''
      tags = " - tags: #{tags.join(", ")}" if respond_to?(:tags) && !tags.empty?
      "#{id} - #{name} - #{region}#{install_status}#{tags}"
    end

    def uninstall
      FileUtils.rm_rf filenames
      FileUtils.rm_rf state_filename
    end

    def update_state(filenames)
      FileUtils.mkdir_p("#{Gamerom::STATE_DIR}/#{repo.name}/#{platform}/#{region}")
      File.write(state_filename, filenames.to_yaml)
    end

    private

    def shell
      @shell ||= Thor::Shell::Color.new
    end
  end
end
