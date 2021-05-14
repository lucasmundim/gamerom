# 'frozen_string_literal' => true

require 'yaml'

REPOSITORIES = Dir["#{File.dirname(__FILE__)}/repo_adapters/*"].map do |file|
  File.basename(file, '.rb')
end

REPOSITORIES.each do |repo|
  require_relative "repo_adapters/#{repo}"
end

module Gamerom
  class Repo
    def self.list
      REPOSITORIES.map do |repo|
        self.new repo
      end
    end

    def initialize name
      @name = name
      @repo = Gamerom::RepoAdapters.const_get(name.capitalize)
    end

    def install game, &block
      @repo.install game, &block
    end

    def find platform, game_identifier
      games(platform).find do |game|
        if Float(game_identifier, exception: false)
          game.id == game_identifier.to_i
        else
          game.name.downcase == game_identifier.downcase
        end
      end
    end

    def games platform, options={}
      platform_database = "#{Gamerom::CACHE_DIR}/#{@name}/#{platform}.yml"
      update_database platform unless File.exists? platform_database
      games = YAML.load_file(platform_database).map { |game|
        Game.new(game.merge(platform: platform, repo: self))
      }

      if !options[:region].nil?
        games = games.select { |game|
          options[:region].nil? || game.region == options[:region]
        }
      end

      if !options[:keyword].nil?
        games = games.select { |game|
          game.name =~ /#{options[:keyword]}/i
        }
      end

      games
    end

    def name
      @name
    end

    def platforms
      @repo.platforms
    end

    def regions platform
      games(platform).map { |game| game.region }.sort.uniq
    end

    def to_s
      @name
    end

    def update_database platform
      games = @repo.games platform
      FileUtils.mkdir_p("#{Gamerom::CACHE_DIR}/#{@name}")
      File.write("#{Gamerom::CACHE_DIR}/#{@name}/#{platform}.yml", games.to_yaml)
    end
  end
end
