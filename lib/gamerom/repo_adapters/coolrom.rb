# frozen_string_literal: true

require 'mechanize'
require 'mechanize/progressbar'
require 'mechanizeprogress'
require 'nokogiri'
require 'rest-client'

module Gamerom
  module RepoAdapters
    class Coolrom
      PLATFORM = {
        'atari2600' => 'Atari 2600',
        'atari5200' => 'Atari 5200',
        'atari7800' => 'Atari 7800',
        'atarijaguar' => 'Atari Jaguar',
        'atarilynx' => 'Atari Lynx',
        'c64' => 'Commodore 64',
        'cps1' => 'CPS1',
        'cps2' => 'CPS2',
        'mame' => 'MAME',
        'namcosystem22' => 'Namco System 22',
        'neogeo' => 'Neo Geo',
        'neogeocd' => 'Neo Geo CD',
        'neogeopocket' => 'Neo Geo Pocket',
        'segacd' => 'Sega CD',
        'dc' => 'Sega Dreamcast',
        'gamegear' => 'Sega Game Gear',
        'genesis' => 'Sega Genesis',
        'mastersystem' => 'Sega Master System',
        'model2' => 'Sega Model 2',
        'saturn' => 'Sega Saturn',
        'psx' => 'Sony Playstation',
        'ps2' => 'Sony Playstation 2',
        'psp' => 'Sony Playstation Portable',
      }

      def self.platforms
        PLATFORM
      end

      def self.games(platform)
        games = []
        sections = ('a'..'z').to_a.unshift("0")

        sections.each do |section|
          print "#{section} "
          page = Nokogiri::HTML(RestClient.get("https://coolrom.com.au/roms/#{platform}/#{section}/"))
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
        games
      end

      def self.install(game)
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'

        response = nil
        agent.progressbar{
          response = agent.get("https://coolrom.com.au/downloader.php?id=#{game.id}")
        }
        if response.code.to_i == 200
          filename = response.filename
          FileUtils.mkdir_p(game.filepath)
          response.save!("#{game.filepath}/#{filename}")
          yield [filename]
        end
      end
    end
  end
end
