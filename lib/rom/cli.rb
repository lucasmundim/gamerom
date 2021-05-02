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

    desc 'info', 'Info for a game'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def info(game_id)
      puts "showing info for game #{game_id} on #{options[:platform]} platform..."
      game = Game.find(options[:platform], game_id)
      if game.nil?
        puts "Game #{game_id} not found"
      end
      puts game
    rescue => e
      puts e.message
      exit 1
    end

    desc 'install', 'Install game'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def install(game_id)
      puts "installing game #{game_id} on #{options[:platform]} platform..."
      game = Game.find(options[:platform], game_id)
      if game.nil?
        puts "Game #{game_id} not found"
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
    option :region, :aliases => ['-r'], type: :string, required: false, desc: "Only install from the specified region"
    def install_all
      games = Game.all options[:platform], options[:region]
      games.each do |game|
        install(game.id)
      end
    rescue => e
      puts e.message
      exit 1
    end

    desc 'list', 'List games'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    option :region, :aliases => ['-r'], type: :string, required: false, desc: "Only install from the specified region"
    def list
      puts "listing avaiable games for #{options[:platform]} platform..."
      games = Game.all options[:platform], options[:region]
      games.each do |game|
        puts game
      end
    rescue => e
      puts e.message
      exit 1
    end

    desc 'platform', 'List avaiable platform'
    option :v, type: :boolean, default: false, desc: "Show verbose backtrace"
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

    desc 'search', 'Search games'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    option :region, :aliases => ['-r'], type: :string, required: false, desc: "Only install from the specified region"
    def search(keyword)
      puts "searching avaiable games for #{options[:platform]} platform..."
      games = Game.all options[:platform], options[:region]
      games.each { |game|
        puts game if game.name =~ /#{keyword}/i
      }
    rescue => e
      puts e.message
      exit 1
    end

    desc 'update', 'Update local database'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    option :v, type: :boolean, default: false, desc: "Show verbose backtrace"
    def update
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
