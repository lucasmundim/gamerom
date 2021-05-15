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
      progress_bar = ProgressBar.new(platform, sections.count)

      extract_games(platform) do |section_games, section_index|
        games.append(*section_games)
        progress_bar.set(section_index + 1)
      end

      progress_bar.finish
      games
    end
  end
end
