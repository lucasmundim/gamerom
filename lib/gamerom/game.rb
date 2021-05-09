# 'frozen_string_literal' => true

require 'fileutils'
require 'ostruct'
require 'yaml'

module Gamerom
  class Game < OpenStruct
    def filenames
      YAML.load_file(self.state_filename).map do |filename|
        "#{self.filepath}/#{filename}"
      end
    end

    def filepath
      "#{Gamerom::GAME_DIR}/#{self.repo.name}/#{self.platform}/#{self.region}"
    end

    def install
      self.repo.install self do |filenames|
        self.update_state filenames
      end
    end

    def installed?
      File.exists? self.state_filename
    end

    def state_filename
      "#{Gamerom::STATE_DIR}/#{self.repo.name}/#{self.platform}/#{self.region}/#{self.id}"
    end

    def to_s
      "#{self.id} - #{self.name} - #{self.region}#{self.installed? ? " (#{shell.set_color 'installed', :green})" : ''}"
    end

    def uninstall
      FileUtils.rm_rf self.filenames
      FileUtils.rm_rf self.state_filename
    end

    def update_state filenames
      FileUtils.mkdir_p("#{Gamerom::STATE_DIR}/#{self.repo.name}/#{self.platform}/#{self.region}")
      File.write(self.state_filename, filenames.to_yaml)
    end

    private
    def shell
      @shell ||= Thor::Shell::Color.new
    end
  end
end
