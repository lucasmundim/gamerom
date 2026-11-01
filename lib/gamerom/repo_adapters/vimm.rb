# frozen_string_literal: true

require 'fileutils'

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
          # Each row: <td><img class="media-icon"><a href="/vault/2640">Mace: The Dark Age</a></td>...
          game_links = page.css('table.hovertable tr td:first-child a[href^="/vault/"]')
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

      # Vimm's Lair protects game pages with a browser challenge, so games have to be
      # downloaded by hand. Prepare the target directory and tell the user what to do.
      def self.install(game)
        FileUtils.mkdir_p(game.filepath)
        raise Gamerom::ManualDownloadRequired, <<~MSG
          vimm.net does not allow automated downloads.
          Download the game from #{game_url(game)} in your browser and save it to:
            #{game.filepath}/
          Then run `gamerom recover -r vimm -p #{game.platform}` to register it.
        MSG
      end

      def self.game_url(game)
        "https://vimm.net/vault/#{game.id}"
      end
    end
  end
end
