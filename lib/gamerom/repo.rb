# frozen_string_literal: true

require 'yaml'

REPOSITORIES = Dir["#{File.dirname(__FILE__)}/repo_adapters/*"].map do |file|
  File.basename(file, '.rb')
end

require_relative 'repo_adapter'
REPOSITORIES.each do |repo|
  require_relative "repo_adapters/#{repo}"
end

module Gamerom
  # Repo - Represents a game ROM repository
  class Repo
    attr_reader :name

    def self.list
      REPOSITORIES.map do |repo|
        new repo
      end
    end

    def initialize(name)
      @name = name
      @repo = Gamerom::RepoAdapters.const_get(name.capitalize)
    end

    def install(game, &block)
      @repo.install game, &block
    end

    def find(platform, game_identifier)
      games(platform).find do |game|
        if Integer(game_identifier, exception: false)
          game.id == game_identifier.to_i
        else
          game.name.downcase == game_identifier.downcase
        end
      end
    end

    def games(platform, options = {})
      platform_database = "#{Gamerom::CACHE_DIR}/#{@name}/#{platform}.yml"
      update_database platform unless File.exist? platform_database
      games = YAML.load_file(platform_database).map do |game|
        Game.new(game.merge(platform: platform, repo: self))
      end

      unless options[:region].nil?
        games.select! do |game|
          game.region == options[:region]
        end
      end

      unless options[:keyword].nil?
        games.select! do |game|
          game.name =~ /#{options[:keyword]}/i
        end
      end

      games
    end

    def platforms
      @repo.platforms
    end

    def regions(platform)
      games(platform).map(&:region).sort.uniq
    end

    def to_s
      @name
    end

    def update_database(platform)
      games = @repo.games platform
      FileUtils.mkdir_p("#{Gamerom::CACHE_DIR}/#{@name}")
      File.write("#{Gamerom::CACHE_DIR}/#{@name}/#{platform}.yml", games.to_yaml)
    end
  end
end
