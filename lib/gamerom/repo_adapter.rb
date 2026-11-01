# frozen_string_literal: true

require 'nokogiri'
require 'rest-client'
require 'uri'

module Gamerom
  # RepoAdapter - Common adapter methods
  module RepoAdapter
    MAX_RETRIES = 5

    # Sites rate limit the section crawl; honor the Retry-After of a 429 instead of failing.
    def nokogiri_get(url)
      retries = 0
      loop do
        return Nokogiri::HTML(RestClient.get(url))
      rescue RestClient::TooManyRequests => e
        retries += 1
        raise if retries > MAX_RETRIES

        delay = (e.response.headers[:retry_after] || 60).to_i
        puts "\nrate limited by #{URI.parse(url).host}, retrying in #{delay}s (#{retries}/#{MAX_RETRIES})"
        sleep delay
      end
    end

    def games(platform)
      games = []

      columns = `tput cols`.to_i
      length = [120, columns].min

      progress_bar = ProgressBar.create(
        title: platform,
        total: sections.count,
        autofinish: true,
        length: length,
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
