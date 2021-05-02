# 'frozen_string_literal' => true

require 'ostruct'

module Rom
  class Game < OpenStruct
    def self.all platform
      games = YAML.load_file("#{Rom::CACHE_DIR}/#{platform}.yml")
      games.map { |game|
        self.new(game.merge(platform: platform))
      }
    end

    def self.find platform, game_id
      self.all(platform).find do |game|
        game.id == game_id.to_i
      end
    end

    def installed?
      basename = "#{Rom::GAME_DIR}/#{self.platform}/#{self.region}/#{self.name}"
      ['zip', '7z', 'rar'].any? do |ext|
        File.exists? "#{basename}.#{ext}"
      end
    end

    def to_s
      "#{self.id} - #{self.name} - #{self.region}"
    end
  end
end
