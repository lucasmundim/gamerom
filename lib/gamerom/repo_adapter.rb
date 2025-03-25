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
      progress_bar = ProgressBar.create(title: platform, total: sections.count, autofinish: true)

      extract_games(platform) do |section_games, section_index|
        games.append(*section_games)
        progress_bar.progress = section_index + 1
      end

      games
    end
  end
end
