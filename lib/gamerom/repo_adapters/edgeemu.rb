# frozen_string_literal: true

require 'mechanize'
require 'uri'
require 'mechanize/progressbar'
require 'mechanizeprogress'

module Gamerom
  module RepoAdapters
    # Edgeemu - An adapter for the Edge Emulation repository website
    class Edgeemu
      extend Gamerom::RepoAdapter

      BASE_URL = 'https://edgeemu.net'

      PLATFORM = {
        'atari-2600' => 'Atari 2600',
        'atari-5200' => 'Atari 5200',
        'atari-7800' => 'Atari 7800',
        'atari-jaguar' => 'Atari Jaguar',
        'atari-jaguar-cd' => 'Atari Jaguar CD',
        'atari-lynx' => 'Atari Lynx',
        'atari-st' => 'Atari ST',
        'bandai-wonderswan' => 'Bandai WonderSwan',
        'colecovision' => 'Coleco ColecoVision',
        'commodore-64' => 'Commodore 64',
        'commodore-amiga' => 'Commodore Amiga',
        'commodore-amiga-cd' => 'Commodore Amiga CD',
        'commodore-amiga-cd32' => 'Commodore Amiga CD32',
        'commodore-plus-4' => 'Commodore Plus-4',
        'commodore-vic-20' => 'Commodore VIC-20',
        'fairchild-channel-f' => 'Fairchild Channel F',
        'gce-vectrex' => 'GCE Vectrex',
        'microsoft-msx' => 'Microsoft MSX / MSX2',
        'nec-pc-engine-cd-turbografx-cd' => 'NEC PC Engine CD / TurboGrafx CD',
        'nec-pc-engine-supergrafx' => 'NEC PC Engine SuperGrafx',
        'nec-pc-engine-turbografx-16' => 'NEC PC Engine / TurboGrafx 16',
        'nintendo-64' => 'Nintendo 64',
        'nintendo-ds' => 'Nintendo DS',
        'nintendo-fds' => 'Nintendo Famicom Disk System (FDS)',
        'nintendo-gameboy' => 'Nintendo Game Boy',
        'nintendo-gameboy-advance' => 'Nintendo Game Boy Advance',
        'nintendo-gameboy-color' => 'Nintendo Game Boy Color',
        'nintendo-gamecube' => 'Nintendo Gamecube',
        'nintendo-nes' => 'Nintendo Entertainment System (NES)',
        'nintendo-satellaview' => 'Nintendo Satellaview',
        'nintendo-snes' => 'Super NES (SNES)',
        'nintendo-virtualboy' => 'Nintendo Virtual Boy',
        'panasonic-3do' => 'Panasonic 3DO',
        'philips-cdi' => 'Philips CDi',
        'rca-studioii' => 'RCA Studio II',
        'sega-32x' => 'Sega 32X',
        'sega-cd' => 'Sega Mega-CD / Sega CD',
        'sega-dreamcast' => 'Sega Dreamcast',
        'sega-gamegear' => 'Sega Game Gear',
        'sega-genesis' => 'Sega Mega Drive / Genesis',
        'sega-pico' => 'Sega PICO',
        'sega-saturn' => 'Sega Saturn',
        'sega-sg1000' => 'Sega SG-1000',
        'sega-sms' => 'Sega Master System / Mark III',
        'sinclair-zx-spectrum-3' => 'Sinclair ZX Spectrum +3',
        'snk-neo-geo-cd' => 'SNK Neo Geo CD',
        'snk-ngpc' => 'SNK Neo Geo Pocket Color',
        'watara-supervision' => 'Watara Supervision',
      }.freeze

      # No-Intro region tags, as they appear in parentheses in the file names
      REGIONS = [
        'World', 'USA', 'Europe', 'Japan', 'Asia', 'Australia', 'Brazil', 'Canada', 'China', 'France',
        'Germany', 'Greece', 'Hong Kong', 'Italy', 'Korea', 'Netherlands', 'Norway', 'Poland', 'Portugal',
        'Russia', 'Scandinavia', 'Spain', 'Sweden', 'Taiwan', 'UK', 'Unknown', 'Latin America'
      ].freeze

      def self.platforms
        PLATFORM
      end

      def self.sections
        ('a'..'z').to_a.unshift('1')
      end

      def self.extract_games(platform)
        sections.each_with_index do |section, index|
          page = nokogiri_get("#{BASE_URL}/browse/#{platform}/#{section}")
          yield page.css('div.item details').map { |item| game(item) }, index
        rescue RestClient::NotFound
          yield [], index
        end
      end

      # Each item looks like:
      #   <details data-name="Espial (USA).zip">
      #     <summary>Espial (USA)</summary>
      #     <p><a href="/download/atari-2600/Espial%20%28USA%29.zip">download</a> ...</p>
      #     <p>hash:&nbsp;<span>931A0BDC</span></p>
      #   </details>
      # The hash is the CRC32 of the ROM, which is used as the game id.
      def self.game(item)
        name = item.at_css('summary').text.strip
        {
          id: item.css('p').find { |p| p.text.start_with?('hash') }.at_css('span').text.strip.to_i(16),
          name: name,
          region: region(name),
          url: "#{BASE_URL}#{item.at_css('a[href^="/download/"]')["href"]}",
        }
      end

      # "Espial (USA)" => "USA", "Game (USA, Europe) (Proto)" => "USA, Europe"
      def self.region(name)
        groups = name.scan(/\(([^)]+)\)/).flatten
        groups.find { |group| REGIONS.include?(group.split(',').first.strip) } || 'Unknown'
      end

      def self.install(game)
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'

        response = nil
        agent.progressbar do
          response = agent.get(game.url)
        end

        return unless response.code.to_i == 200

        # The Content-Disposition header ends with a stray ";" that Mechanize cannot parse,
        # so it falls back to the percent-encoded URL basename. Decode it instead.
        filename = URI.decode_uri_component(File.basename(URI.parse(game.url).path))
        FileUtils.mkdir_p(game.filepath)
        response.save!("#{game.filepath}/#{filename}")
        puts "Downloaded: #{filename}"
        yield [filename]
      end
    end
  end
end
