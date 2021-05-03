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
        shell.say "Game #{game_identifier} not found", :red
      end
      puts game
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'install GAME_IDENTIFIER', 'Install game GAME_IDENTIFIER (id/name)'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def install(game_identifier)
      puts "installing game #{game_identifier} on #{options[:platform]} platform..."
      game = Game.find(options[:platform], game_identifier)
      if game.nil?
        shell.say "Game #{game_identifier} not found", :red
        return
      end
      if game.installed?
        shell.say "Game already installed", :yellow
        return
      end
      puts game
      game.install
      shell.say "Game installed", :green
    rescue => e
      shell.say e.message, :red
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
      shell.say e.message, :red
      exit 1
    end

    desc 'list', 'List games'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    option :region, :aliases => ['-r'], type: :string, required: false, desc: "Only from specified region"
    def list
      puts "listing available games for #{options[:platform]} platform..."
      games = Game.all options[:platform], region: options[:region]
      print_game_table(games)
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'platform', 'List available platforms'
    def platform
      puts "listing available platforms..."
      platforms = { platforms: Rom::PLATFORM }
      puts platforms.to_yaml
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'regions', 'List available regions'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def regions
      puts "listing available regions for #{options[:platform]} platform..."
      games = Game.all options[:platform]
      puts games.map { |game| game.region }.sort.uniq
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'search KEYWORD', 'Search games by KEYWORD'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    option :region, :aliases => ['-r'], type: :string, required: false, desc: "Only from specified region"
    def search(keyword)
      puts "searching available games for #{options[:platform]} platform..."
      games = Game.all options[:platform], region: options[:region], keyword: keyword
      print_game_table(games)
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'update_database', 'Update local database'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def update_database
      puts "updating #{options[:platform]} platform..."
      Game.update_database options[:platform]
      shell.say 'Game database updated', :green
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'version', 'Print program version'
    def version
      puts Rom::VERSION
    end

    private
    def print_game_table(games)
      results = []
      results << ['ID', 'NAME', 'REGION', 'INSTALLED']
      games.each do |game|
        results << [
          game.id,
          game.name,
          game.region,
          game.installed? ? shell.set_color('installed', :green) : '-',
        ]
      end
      shell.print_table(results)
    end
  end
end
