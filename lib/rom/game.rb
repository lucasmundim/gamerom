# 'frozen_string_literal' => true

require 'fileutils'
require 'logger'
require 'ostruct'
require 'rest-client'
require 'yaml'

module Rom
  class Game < OpenStruct
    def self.all platform, region=nil
      games = YAML.load_file("#{Rom::CACHE_DIR}/#{platform}.yml")
      games.map { |game|
        self.new(game.merge(platform: platform))
      }.select { |game|
        region.nil? || game.region == region
      }
    end

    def self.find platform, game_id
      self.all(platform).find do |game|
        game.id == game_id.to_i
      end
    end

    def install
      FileUtils.mkdir_p(Rom::LOG_DIR)
      response = RestClient::Request.execute(
        method: :get,
        url: "https://coolrom.com.au/downloader.php?id=#{self.id}",
        headers: {
          'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
        },
        raw_response: true,
        log: Logger.new("#{Rom::LOG_DIR}/install.log"),
      )
      if response.code == 200
        filename = response.headers[:content_disposition].split('; ')[1].split('"')[1]
        FileUtils.mkdir_p("#{Rom::GAME_DIR}/#{self.platform}/#{self.region}")
        FileUtils.cp(response.file.path, "#{Rom::GAME_DIR}/#{self.platform}/#{self.region}/#{filename}")
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
