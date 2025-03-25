# frozen_string_literal: true

module Gamerom
  # GameInfo - Extracts region and tags from game name
  class GameInfo
    REGIONS = {
      '1' => 'Japan & Korea',
      '4' => 'USA & Brazil - NTSC',
      '5' => 'NTSC',
      '8' => 'PAL',
      'A' => 'Australia',
      'As' => 'Asia',
      'B' => 'Brazil',
      'C' => 'Canada',
      'Ch' => 'China',
      'D' => 'Netherlands (Dutch)',
      'E' => 'Europe',
      'F' => 'France',
      'FC' => 'French Canadian',
      'FN' => 'Finland',
      'G' => 'Germany',
      'GR' => 'Greece',
      'H' => 'Holland',
      'HK' => 'Hong Kong',
      'I' => 'Italy',
      'J' => 'Japan',
      'JUE' => 'Japan & USA & Europe',
      'K' => 'Korea',
      'Nl' => 'Netherlands',
      'NL' => 'Netherlands',
      'No' => 'Norway',
      'PD' => 'Public Domain',
      'R' => 'Russia',
      'S' => 'Spain',
      'Sw' => 'Sweden',
      'SW' => 'Sweden',
      'U' => 'USA',
      'UK' => 'England',
      'Unk' => 'Unknown Country',
      'Unl' => 'Unlicensed',
      'PAL' => 'PAL regions (Australia, Europe)',
      'NTSC' => 'NTSC regions (Japan, USA, Latin America)',
    }.freeze

    TAGS = {
      '!' => :good,
      '!p' => :pending,
      'a' => :alternate,
      'b' => :bad,
      'BF' => :bung,
      'c' => :checksum,
      'C' => :color,
      'f' => :fixed,
      'h' => :hack,
      'J' => :japanese_translation,
      'o' => :overdump,
      'p' => :pirate,
      'PC10' => :pc10,
      'S' => :super,
      'T-' => :old_translation,
      't' => :trained,
      'T+' => :newer_translation,
      'VS' => :vs,
      'x' => :bad_checksum,
    }.freeze

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def region
      identifiers = @name.scan(/\((?<region>[A-Za-z0-9]+)\)/).flatten
      region_id = identifiers.find { |i| REGIONS.include? i }
      if region_id
        REGIONS[region_id]
      else
        'USA'
      end
    end

    def tags
      tags = []
      codes = @name.scan(/\[(?<code>[^\]]+)\]/).flatten
      codes.each do |code|
        code = Regexp.last_match(1) if code.match(/^(?<code>[abcfhop])[0-9]*/)
        tags << TAGS[code] if TAGS.include?(code)
      end
      tags
    end
  end
end
