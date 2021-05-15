# frozen_string_literal: true

require 'nokogiri'
require 'rest-client'

module Gamerom
  # RepoAdapter - Common adapter methods
  module RepoAdapter
    def nokogiri_get(url)
      Nokogiri::HTML(RestClient.get(url))
    end
  end
end
