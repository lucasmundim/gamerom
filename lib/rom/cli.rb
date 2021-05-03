# frozen_string_literal: true

require 'thor'

module Rom
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc 'config', 'Show config'
    def config
      cfg = {
        ROM_ROOT: Rom::ROM_ROOT,
        CACHE_DIR: Rom::CACHE_DIR,
        GAME_DIR: Rom::GAME_DIR,
        LOG_DIR: Rom::LOG_DIR,
      }
      pp cfg
    end

    desc 'info GAME_IDENTIFIER', 'Info for game GAME_IDENTIFIER (id/name)'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def info(game_identifier)
      puts "showing info for game #{game_identifier} on #{options[:platform]} platform..."
      game = Game.find(options[:platform], game_identifier)
      if game.nil?
        puts "Game #{game_identifier} not found"
      end
      puts game
    rescue => e
      puts e.message
      exit 1
    end

    desc 'install GAME_IDENTIFIER', 'Install game GAME_IDENTIFIER (id/name)'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def install(game_identifier)
      puts "installing game #{game_identifier} on #{options[:platform]} platform..."
      game = Game.find(options[:platform], game_identifier)
      if game.nil?
        puts "Game #{game_identifier} not found"
        return
      end
      if game.installed?
        puts "Game already installed"
        return
      end
      puts game
      game.install
      puts "Game installed"
    rescue => e
      puts e.message
      exit 1
    end

    desc 'install_all', 'Install all games'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    option :region, :aliases => ['-r'], type: :string, required: false, desc: "Only from specified region"
    def install_all
      games = Game.all options[:platform], region: options[:region]
      games.each do |game|
        install(game.id)
      end
    rescue => e
      puts e.message
      exit 1
    end

    desc 'list', 'List games'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    option :region, :aliases => ['-r'], type: :string, required: false, desc: "Only from specified region"
    def list
      puts "listing avaiable games for #{options[:platform]} platform..."
      games = Game.all options[:platform], region: options[:region]
      games.each do |game|
        puts game
      end
    rescue => e
      puts e.message
      exit 1
    end

    desc 'platform', 'List avaiable platforms'
    def platform
      puts "listing avaiable platforms..."
      platforms = { platforms: Rom::PLATFORM }
      puts platforms.to_yaml
    rescue => e
      puts e.message
      exit 1
    end

    desc 'regions', 'List avaiable regions'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def regions
      puts "listing avaiable regions for #{options[:platform]} platform..."
      games = Game.all options[:platform]
      puts games.map { |game| game.region }.sort.uniq
    rescue => e
      puts e.message
      exit 1
    end

    desc 'search KEYWORD', 'Search games by KEYWORD'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    option :region, :aliases => ['-r'], type: :string, required: false, desc: "Only from specified region"
    def search(keyword)
      puts "searching avaiable games for #{options[:platform]} platform..."
      games = Game.all options[:platform], region: options[:region], keyword: keyword
      games.each { |game|
        puts game
      }
    rescue => e
      puts e.message
      exit 1
    end

    desc 'update_database', 'Update local database'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def update_database
      puts "updating #{options[:platform]} platform..."
      Game.update_database options[:platform]
      puts 'Game database updated'
    rescue => e
      puts e.message
      exit 1
    end

    desc 'version', 'Print program version'
    def version
      puts Rom::VERSION
    end
  end
end
