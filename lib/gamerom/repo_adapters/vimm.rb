# frozen_string_literal: true

require 'mechanize'
require 'mechanize/progressbar'
require 'mechanizeprogress'

module Gamerom
  module RepoAdapters
    # Vimm - An adapter for the Vimm's Lair repository website
    class Vimm
      extend Gamerom::RepoAdapter

      PLATFORM = {
        '32X' => 'Sega 32X',
        'Atari2600' => 'Atari 2600',
        'Atari5200' => 'Atari 5200',
        'Atari7800' => 'Atari 7800',
        'Dreamcast' => 'Dreamcast',
        'DS' => 'Nintendo DS',
        'GameCube' => 'GameCube',
        'GB' => 'Game Boy',
        'GBA' => 'Game Boy Advance',
        'GBC' => 'Game Boy Color',
        'Genesis' => 'Genesis',
        'GG' => 'Game Gear',
        'Lynx' => 'Lynx',
        'N64' => 'Nintendo 64',
        'NES' => 'Nintendo',
        'PS1' => 'PlayStation',
        'PS2' => 'PlayStation 2',
        'PS3' => 'PlayStation 3',
        'PSP' => 'PlayStation Portable',
        'Saturn' => 'Saturn',
        'SegaCD' => 'Sega CD',
        'SMS' => 'Master System',
        'SNES' => 'Super Nintendo',
        'TG16' => 'TurboGrafx-16',
        'TGCD' => 'TurboGrafx-CD',
        'VB' => 'Virtual Boy',
        'Wii' => 'Wii',
        'WiiWare' => 'WiiWare',
        'Xbox' => 'Xbox',
        'Xbox360' => 'Xbox 360',
      }.freeze

      def self.platforms
        PLATFORM
      end

      def self.sections
        ('a'..'z').to_a.unshift('number')
      end

      def self.extract_games(platform)
        sections.each_with_index do |section, index|
          page = nokogiri_get("https://vimm.net/vault/?p=list&system=#{platform}&section=#{section}")
          game_links = page.css('table.hovertable td:first-child a:first-child')
          yield game_links.map { |game_link| game(game_link) }, index
        rescue RestClient::NotFound
        end
      end

      def self.game(game_link)
        {
          id: game_link['href'].split('/').last.to_i,
          name: game_link.text,
          region: 'USA',
        }
      end

      def self.install(game)
        FileUtils.mkdir_p(game.filepath)
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'
        page = agent.get("https://vimm.net/vault/#{game.id}")
        form = page.form_with(id: 'download_form')

        filenames = []
        game_files = []
        multiple_disks = page.css('#download_disc_number')

        if multiple_disks.empty?
          game_files << { id: form['mediaId'], name: 'single file rom' }
        else
          puts 'multiple discs detected'
          game_files.concat(multiple_disks.children[1..-2].map { |disk| { name: disk.text, id: disk['value'] } })
        end

        game_files.each do |game_file|
          puts "downloading #{game_file[:name]}"
          form.method = 'GET'
          button = form.button_with(type: 'submit')
          response = nil
          form['mediaId'] = game_file[:id]
          agent.progressbar do
            response = form.click_button(button)
          end

          break unless response.code.to_i == 200

          filename = response.filename
          response.save!("#{game.filepath}/#{filename}")
          filenames << filename
        end
        yield filenames
      end
    end
  end
end
