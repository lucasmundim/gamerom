# frozen_string_literal: true

require 'base64'
require 'json'
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
          yield [], index
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
        form = page.form_with(id: 'dl_form')

        filenames = []
        media_files(page, form).each do |media_file|
          puts "downloading #{media_file[:name]}"
          form.method = 'GET'
          button = form.button_with(type: 'submit')
          response = nil
          form['mediaId'] = media_file[:id]
          agent.progressbar do
            response = form.click_button(button)
          end

          break unless response.code.to_i == 200

          filename = response.filename
          response.save!("#{game.filepath}/#{filename}")
          filenames << filename
          puts "Downloaded: #{filename}"
        end
        yield filenames
      end

      # Multi-disc games list every disc in the JavaScript `allMedia` constant;
      # fall back to the form's mediaId when it is missing or unparseable.
      def self.media_files(page, form)
        single_file = [{ id: form['mediaId'], name: 'single file rom' }]
        all_media_js = page.body.match(/const allMedia=(\[.*?\]);/m)
        return single_file unless all_media_js

        all_media = JSON.parse(all_media_js[1])
        return single_file if all_media.empty?

        puts 'multiple discs detected' if all_media.size > 1
        all_media.map do |media|
          # GoodTitle is base64 encoded
          title = media['GoodTitle'] ? Base64.decode64(media['GoodTitle']) : 'Disc'
          { id: media['ID'].to_s, name: title }
        end
      rescue JSON::ParserError => e
        puts "Error parsing media data: #{e.message}"
        single_file
      end
    end
  end
end
