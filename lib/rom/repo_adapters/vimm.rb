# frozen_string_literal: true

require 'nokogiri'
require 'rest-client'

module Rom
  module RepoAdapters
    class Vimm
      PLATFORM = {
        'Dreamcast' => 'Dreamcast',
        'DS' => 'Nintendo DS',
        'GameCube' => 'GameCube',
        'GB' => 'Game Boy',
        'GBA' => 'Game Boy Advance',
        'GBC' => 'Game Boy Color',
        'Genesis' => 'Genesis',
        'N64' => 'Nintendo 64',
        'NES' => 'Nintendo',
        'PS1' => 'PlayStation',
        'PS2' => 'PlayStation 2',
        'PS3' => 'PlayStation 3',
        'PSP' => 'PlayStation Portable',
        'Saturn' => 'Saturn',
        'SNES' => 'Super Nintendo',
        'Wii' => 'Wii',
        'WiiWare' => 'WiiWare',
      }

      def self.platforms
        PLATFORM
      end

      def self.games(platform)
        games = []
        sections = ('a'..'z').to_a.unshift("number")

        sections.each do |section|
          print "#{section} "
          page = Nokogiri::HTML(RestClient.get("https://vimm.net/vault/?p=list&system=#{platform}&section=#{section}"))
          games.append *page.css('table.hovertable td:first-child a:first-child').map { |game|
            {
              id: game['href'].split('/').last.to_i,
              name: game.text,
              region: 'USA',
            }
          }
        end
        games
      end

      def self.install(game)
        response = RestClient::Request.execute(
          method: :get,
          url: "https://download4.vimm.net/download/?mediaId=#{game.id}",
          headers: {
            'Connection': 'keep-alive',
            'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="90", "Google Chrome";v="90"',
            'sec-ch-ua-mobile': '?0',
            'Upgrade-Insecure-Requests': '1',
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
            'Sec-Fetch-Site': 'same-site',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-User': '?1',
            'Sec-Fetch-Dest': 'document',
            'Referer': 'https://vimm.net/',
            'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
          },
          raw_response: true,
        )
        if response.code == 200
          filename = response.headers[:content_disposition].split('; ')[1].split('"')[1]
          yield response.file.path, filename
        end
      end
    end
  end
end
