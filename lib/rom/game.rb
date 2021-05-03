# 'frozen_string_literal' => true

require 'fileutils'
require 'logger'
require 'nokogiri'
require 'ostruct'
require 'rest-client'
require 'yaml'

module Rom
  class Game < OpenStruct
    def self.all platform, options={}
      games = YAML.load_file("#{Rom::CACHE_DIR}/#{platform}.yml").map { |game|
        self.new(game.merge(platform: platform))
      }

      if !options[:region].nil?
        games = games.select { |game|
          options[:region].nil? || game.region == options[:region]
        }
      end

      if !options[:keyword].nil?
        games = games.select { |game|
          game.name =~ /#{options[:keyword]}/i
        }
      end

      games
    end

    def self.find platform, game_identifier
      self.all(platform).find do |game|
        if Float(game_identifier, exception: false)
          game.id == game_identifier.to_i
        else
          game.name == game_identifier
        end

      end
    end

    def self.update_database platform
      games = []
      letters = ('a'..'z').to_a.unshift("0")

      letters.each do |letter|
        print "#{letter} "
        page = Nokogiri::HTML(RestClient.get("https://coolrom.com.au/roms/#{platform}/#{letter}/"))
        regions = page.css('input.region').map { |i| i["name"] }
        regions.each do |region|
          games.append *page.css("div.#{region} a").map { |game|
            {
              id: game['href'].split('/')[3].to_i,
              name: game.text,
              region: region,
            }
          }
        end
      end
      puts

      FileUtils.mkdir_p(Rom::CACHE_DIR)
      File.write("#{Rom::CACHE_DIR}/#{platform}.yml", games.to_yaml)
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
