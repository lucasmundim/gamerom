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
      puts game.filename if game.installed?
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'install GAME_IDENTIFIER', 'Install game GAME_IDENTIFIER (id/name)'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def install(game_identifier)
      game = Game.find(options[:platform], game_identifier)
      if game.nil?
        shell.say "Game #{game_identifier} not found", :red
        return
      end
      puts "installing game #{game.id} - #{game.name} - #{game.region} on #{options[:platform]} platform..."
      if game.installed?
        shell.say "Game already installed", :yellow
        return
      end
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
        install(game.id) unless game.installed?
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

    desc 'recover', 'Try to recover state from already downloaded roms'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def recover
      puts "recovering state of roms for #{options[:platform]} platform..."
      games = Game.all options[:platform]
      games_not_found = []
      games.each do |game|
        filename = nil
        basename = "#{Rom::GAME_DIR}/#{options[:platform]}/#{game[:region]}/#{game[:name]}"
        ['zip', '7z', 'rar'].each do |ext|
          if File.exists? "#{basename}.#{ext}"
            filename = "#{basename}.#{ext}"
          end
        end

        if filename
          game.update_state File.basename(filename)
          puts "Found game #{game[:name]}"
        else
          games_not_found << game[:name]
        end
      end
      if games_not_found.count > 0
        puts "Games not found:"
        puts games_not_found
      end
    rescue => e
      puts e.message
      exit 1
    end

    desc 'regions', 'List available regions'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def regions
      puts "listing available regions for #{options[:platform]} platform..."
      puts Game.regions options[:platform]
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

    desc 'stats', 'Show platform stats'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def stats
      puts "stats for #{options[:platform]} platform..."
      games = Game.all options[:platform]
      total = games.count
      installed = games.select { |game| game.installed? }.count
      size = 0
      if File.exists? "#{Rom::GAME_DIR}/#{options[:platform]}"
        size = `du -hs "#{Rom::GAME_DIR}/#{options[:platform]}/"|awk '{ print $1 }'`
      end
      puts "  All: #{installed}/#{total} - size: #{size}"
      Game.regions(options[:platform]).each do |region|
        games = Game.all(options[:platform], region: region)
        total = games.count
        installed = games.select { |game| game.installed? }.count
        size = 0
        if File.exists? "#{Rom::GAME_DIR}/#{options[:platform]}/#{region}"
          size = `du -hs "#{Rom::GAME_DIR}/#{options[:platform]}/#{region}/"|awk '{ print $1 }'`
        end
        puts "  #{region}: #{installed}/#{total} - size: #{size}"
      end
      puts
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'stats_all', 'Show stats for all platforms'
    def stats_all
      Rom::PLATFORM.keys.each do |platform|
        a = Rom::Cli.new
        a.options = { platform: platform }
        a.stats
      end
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'uninstall GAME_IDENTIFIER', 'Uninstall game GAME_IDENTIFIER (id/name)'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def uninstall(game_identifier)
      game = Game.find(options[:platform], game_identifier)
      if game.nil?
        shell.say "Game #{game_identifier} not found", :red
        return
      end
      puts "uninstalling game #{game.id} - #{game.name} - #{game.region} on #{options[:platform]} platform..."
      if !game.installed?
        shell.say "Game is not installed", :yellow
        return
      end
      game.uninstall
      shell.say "Game uninstalled", :green
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'update_all_databases', 'Update all local databases'
    def update_all_databases
      Rom::PLATFORM.keys.each do |platform|
        a = Rom::Cli.new
        a.options = { platform: platform }
        a.update_database
      end
      shell.say 'All game databases updated', :green
    rescue => e
      shell.say e.message, :red
      exit 1
    end

    desc 'update_database', 'Update local database'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to use", enum: Rom::PLATFORM.keys
    def update_database
      puts "updating #{options[:platform]} platform..."
      Game.update_database options[:platform]
      shell.say "Game database updated for platform #{options[:platform]}", :green
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

      games.each do |game|
        results << [
          game.id,
          game.name,
          game.region,
          game.installed? ? shell.set_color('installed', :green) : '-',
        ]
      end
      results.sort_by! { |columns| columns[1] }
      results.unshift ['ID', 'NAME', 'REGION', 'INSTALLED']
      shell.print_table(results)
    end
  end
end
