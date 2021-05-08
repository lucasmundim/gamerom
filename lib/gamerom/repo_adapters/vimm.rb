# frozen_string_literal: true

require 'mechanize'
require 'nokogiri'
require 'rest-client'

module Gamerom
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
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'
        page = agent.get("https://vimm.net/vault/#{game.id}")
        form = page.form_with(:id => 'download_form')
        form.action = "https://download4.vimm.net/download/?mediaId=#{game.id}"
        form.method = 'GET'
        button = form.button_with(:type => "submit")
        response = form.click_button(button)
        if response.code.to_i == 200
          filename = response.filename
          FileUtils.mkdir_p(game.filepath)
          response.save!("#{game.filepath}/#{filename}")
          yield filename
        end
      end
    end
  end
end
