# frozen_string_literal: true

require 'cgi'
require 'mechanize'
require 'mechanize/progressbar'
require 'mechanizeprogress'
require 'nokogiri'
require 'rest-client'

module Gamerom
  module RepoAdapters
    class Romnation
      PLATFORM = {
        'amstrad' => 'Amstrad',
        'atari2600' => 'Atari 2600',
        'atari5200' => 'Atari 5200',
        'atari7800' => 'Atari 7800',
        'atarijaguar' => 'Atari Jaguar',
        'atarilynx' => 'Atari Lynx',
        'colecovision' => 'ColecoVision',
        'commodore64' => 'Commodore 64',
        'gamegear' => 'Game Gear',
        'gb' => 'Game Boy',
        'gbc' => 'Game Boy Color',
        'gcdvectrex' => 'Vectrex',
        'genesis' => 'Genesis',
        'intellivision' => 'Intellivision',
        'mame' => 'MAME',
        'msx1' => 'MSX',
        'msx2' => 'MSX2',
        'mtx' => 'MTX',
        'n64' => 'N64',
        'neogeocd' => 'Neo Geo CD',
        'neogeopocket' => 'Neo Geo Pocket',
        'nes' => 'NES',
        'oric' => 'Oric',
        'pce' => 'PC Engine',
        'radioshackcolorcomputer' => 'TRS-80',
        'samcoupe' => 'SAM Coupé',
        'segacd' => 'Sega CD',
        'segamastersystem' => 'Master System',
        'snes' => 'SNES',
        'thompsonmo5' => 'Thomson MO5',
        'virtualboy' => 'Virtual Boy',
        'watara' => 'Watara Supervision',
        'wonderswan' => 'WonderSwan',
      }

      def self.platforms
        PLATFORM
      end

      def self.games(platform)
        games = []
        sections = ('a'..'z').to_a.unshift("0")
        progress_bar = ProgressBar.new(platform, sections.count)
        sections.each_with_index do |section, index|
          page = Nokogiri::HTML(RestClient.get("https://www.romnation.net/srv/roms/#{platform}/#{section}/sort-title.html"))
          pages = ['1']
          pages = page.css('.pagination').first.css('a').map(&:text).map(&:strip).reject(&:empty?) unless page.css('.pagination').empty?
          pages.each do |p|
            page = Nokogiri::HTML(RestClient.get("https://www.romnation.net/srv/roms/#{platform}/#{section}/page-#{p}_sort-title.html"))
            games.append *page.css('table.listings td.title a').map { |game|
              game_info = GameInfo.new(game.text)
              {
                id: game['href'].split('/')[3].to_i,
                name: game.text,
                region: game_info.region,
                tags: game_info.tags,
              }
            }
          end
          progress_bar.set(index+1)
        end
        progress_bar.finish
        games
      end

      def self.install(game)
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'
        page = agent.get("https://www.romnation.net/download/rom/#{game.id}")

        response = nil
        agent.progressbar{
          response = page.link_with(:text => 'Download This Rom').click
        }
        if response.code.to_i == 200
          filename = CGI.unescape(response.filename.split('_host=').first)
          FileUtils.mkdir_p(game.filepath)
          response.save!("#{game.filepath}/#{filename}")
          yield [filename]
        end
      end
    end
  end
end
