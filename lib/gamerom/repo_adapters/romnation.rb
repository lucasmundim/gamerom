# frozen_string_literal: true

require 'cgi'
require 'mechanize'
require 'mechanize/progressbar'
require 'mechanizeprogress'

module Gamerom
  module RepoAdapters
    # Romnation - An adapter for the ROMNation repository website
    class Romnation
      extend Gamerom::RepoAdapter

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
      }.freeze

      def self.platforms
        PLATFORM
      end

      def self.sections
        ('a'..'z').to_a.unshift('0')
      end

      def self.extract_games(platform)
        sections.each_with_index do |section, index|
          pages = extract_pages(platform, section)
          yield extract_games_from_section_pages(platform, section, pages), index
        end
      end

      def self.extract_pages(platform, section)
        page = nokogiri_get("https://www.romnation.net/srv/roms/#{platform}/#{section}/sort-title.html")
        pages = ['1']
        pages = page.css('.pagination').first.css('a').map(&:text).map(&:strip).reject(&:empty?) unless page.css('.pagination').empty?
        pages
      end

      def self.extract_games_from_section_pages(platform, section, pages)
        pages.reduce([]) do |section_games, p|
          page = nokogiri_get("https://www.romnation.net/srv/roms/#{platform}/#{section}/page-#{p}_sort-title.html")
          games_links = page.css('table.listings td.title a')
          section_games.append(*games_links.map { |game_link| game(game_link) })
        end
      end

      def self.game(game_link)
        game_info = GameInfo.new(game_link.text)
        {
          id: game_link['href'].split('/')[3].to_i,
          name: game_link.text,
          region: game_info.region,
          tags: game_info.tags,
        }
      end

      def self.install(game)
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'
        page = agent.get("https://www.romnation.net/download/rom/#{game.id}")

        response = nil
        agent.progressbar do
          response = page.link_with(text: 'Download This Rom').click
        end

        return unless response.code.to_i == 200

        filename = CGI.unescape(response.filename.split('_host=').first)
        FileUtils.mkdir_p(game.filepath)
        response.save!("#{game.filepath}/#{filename}")
        yield [filename]
      end
    end
  end
end
