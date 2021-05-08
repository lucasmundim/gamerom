# frozen_string_literal: true

require 'nokogiri'
require 'rest-client'

module Rom
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
      end

      def self.install(game)
        response = RestClient::Request.execute(
          method: :get,
          url: "https://coolrom.com.au/downloader.php?id=#{game.id}",
          headers: {
            'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
          },
          raw_response: true,
        )
        if response.code == 200
          filename = response.headers[:content_disposition].split('; ')[1].split('"')[1]
          FileUtils.mkdir_p(game.filepath)
          FileUtils.cp(response.file.path, "#{game.filepath}/#{filename}")
          yield filename
        end
      end
    end
  end
end
