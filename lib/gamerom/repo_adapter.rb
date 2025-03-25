# frozen_string_literal: true

require 'nokogiri'
require 'rest-client'

module Gamerom
  # RepoAdapter - Common adapter methods
  module RepoAdapter
    def nokogiri_get(url)
      Nokogiri::HTML(RestClient.get(url))
    end

    def games(platform)
      games = []
      progress_bar = ProgressBar.create(
        title: platform,
        total: sections.count,
        autofinish: true,
        length: 80,
        format: "%t: %b\e[0;93m\u{15E7}\e[0m%i %j%% %e",
        progress_mark: ' ',
        remainder_mark: "\e[0;34m\u{FF65}\e[0m"
      )

      extract_games(platform) do |section_games, section_index|
        games.append(*section_games)
        progress_bar.progress = section_index + 1
      end

      games
    end
  end
end
