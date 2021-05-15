# frozen_string_literal: true

require 'mechanize'
require 'mechanize/progressbar'
require 'mechanizeprogress'
require 'nokogiri'
require 'rest-client'

module Gamerom
  module RepoAdapters
    # Vimm - An adapter for the Vimm's Lair repository website
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
      }.freeze

      def self.platforms
        PLATFORM
      end

      def self.games(platform)
        games = []
        sections = ('a'..'z').to_a.unshift('number')
        progress_bar = ProgressBar.new(platform, sections.count)
        sections.each_with_index do |section, index|
          page = Nokogiri::HTML(RestClient.get("https://vimm.net/vault/?p=list&system=#{platform}&section=#{section}"))
          games.append(*page.css('table.hovertable td:first-child a:first-child').map do |game|
            {
              id: game['href'].split('/').last.to_i,
              name: game.text,
              region: 'USA',
            }
          end)
          progress_bar.set(index + 1)
        end
        progress_bar.finish
        games
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
