# frozen_string_literal: true

require 'thor'

module Gamerom
  # Cli - Main cli commands
  class Cli < Thor
    class_option :verbose, aliases: ['-v'], type: :boolean, default: false, desc: 'Show verbose backtrace'

    def self.exit_on_failure?
      true
    end

    desc 'config', 'Show config'
    def config
      cfg = {
        ROM_ROOT: Gamerom::ROM_ROOT,
        CACHE_DIR: Gamerom::CACHE_DIR,
        GAME_DIR: Gamerom::GAME_DIR,
        LOG_DIR: Gamerom::LOG_DIR,
      }
      pp cfg
    end

    desc 'info GAME_IDENTIFIER', 'Info for game GAME_IDENTIFIER (id/name)'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    def info(*args)
      game_identifier = args.join(' ')
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      puts "showing info for game #{game_identifier} on #{options[:platform]} platform on #{options[:repo]} repo..."
      game = repo.find(options[:platform], game_identifier)
      if game.nil?
        shell.say "Game #{game_identifier} not found", :red
      else
        puts game
        puts game.filenames if game.installed?
      end
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'install GAME_IDENTIFIER', 'Install game GAME_IDENTIFIER (id/name)'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    def install(*args)
      game_identifier = args.join(' ')
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      game = repo.find(options[:platform], game_identifier)
      if game.nil?
        shell.say "Game #{game_identifier} not found", :red
        return
      end
      puts "installing game #{game.id} - #{game.name} - #{game.region} on #{options[:platform]} platform on #{options[:repo]} repo..."
      if game.installed?
        shell.say 'Game already installed', :yellow
        return
      end
      game.install
      shell.say 'Game installed', :green
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'install_all', 'Install all games'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    option :region, aliases: ['-g'], type: :string, required: false, desc: 'Only from specified region'
    def install_all
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      games = repo.games options[:platform], region: options[:region]
      games.each do |game|
        install(game.id) unless game.installed?
      end
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'list', 'List available games'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    option :region, aliases: ['-g'], type: :string, required: false, desc: 'Only from specified region'
    def list
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      puts "listing available games for #{options[:platform]} platform on #{options[:repo]} repo..."
      games = repo.games options[:platform], region: options[:region]
      print_game_table(games)
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'platforms', 'List available platforms'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    def platforms
      puts "listing available platforms for #{options[:repo]} repo..."
      platforms = { platforms: Repo.new(options[:repo]).platforms }
      puts platforms.to_yaml
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'recover', 'Try to recover state from already downloaded roms'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    def recover
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      puts "recovering state of roms for #{options[:platform]} platform on #{options[:repo]} repo..."
      games = repo.games options[:platform]
      games_not_found = []
      games.each do |game|
        filename = nil
        basename = "#{Gamerom::GAME_DIR}/#{repo.name}/#{options[:platform]}/#{game[:region]}/#{game[:name]}"
        %w[zip 7z rar].each do |ext|
          fullname = "#{basename}.#{ext}"
          filename = fullname if File.exist? fullname
        end

        if filename
          game.update_state File.basename(filename)
          puts "Found game #{game[:name]}"
        else
          games_not_found << game[:name]
        end
      end
      if games_not_found.count.positive?
        puts 'Games not found:'
        puts games_not_found
      end
    rescue StandardError => e
      puts e.message
      exit 1
    end

    desc 'regions', 'List available regions'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    def regions
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      puts "listing available regions for #{options[:platform]} platform on #{options[:repo]} repo..."
      puts repo.regions options[:platform]
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'repo', 'List available repo'
    def repo
      puts 'listing available repo...'
      puts Repo.list
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'search KEYWORD', 'Search games by KEYWORD'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    option :region, aliases: ['-g'], type: :string, required: false, desc: 'Only from specified region'
    option :install, aliases: ['-I'], type: :boolean, required: false, desc: 'Install search results'
    def search(*args)
      keyword = args.join(' ')
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      puts "searching available games for #{options[:platform]} platform on #{options[:repo]} repo..."
      games = repo.games options[:platform], region: options[:region], keyword: keyword
      if options[:install]
        games.each do |game|
          install(game.id) unless game.installed?
        end
      else
        print_game_table(games)
      end
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'stats', 'Show platform stats'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    def stats
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      puts "stats for #{options[:platform]} platform on #{options[:repo]} repo..."
      games = repo.games options[:platform]
      total = games.count
      installed = games.select(&:installed?).count
      size = 0
      if File.exist? "#{Gamerom::GAME_DIR}/#{repo.name}/#{options[:platform]}"
        size = `du -hs "#{Gamerom::GAME_DIR}/#{repo.name}/#{options[:platform]}/"|awk '{ print $1 }'`
      end
      puts "  All: #{installed}/#{total} - size: #{size}"
      repo.regions(options[:platform]).each do |region|
        games = repo.games(options[:platform], region: region)
        total = games.count
        installed = games.select(&:installed?).count
        size = 0
        if File.exist? "#{Gamerom::GAME_DIR}/#{repo.name}/#{options[:platform]}/#{region}"
          size = `du -hs "#{Gamerom::GAME_DIR}/#{repo.name}/#{options[:platform]}/#{region}/"|awk '{ print $1 }'`
        end
        puts "  #{region}: #{installed}/#{total} - size: #{size}"
      end
      puts
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'stats_all', 'Show stats for all platforms'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    def stats_all
      repo = Repo.new(options[:repo])
      repo.platforms.each_key do |platform|
        a = Gamerom::Cli.new
        a.options = { platform: platform, repo: options[:repo] }
        a.stats
      end
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'uninstall GAME_IDENTIFIER', 'Uninstall game GAME_IDENTIFIER (id/name)'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    def uninstall(*args)
      game_identifier = args.join(' ')
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      game = repo.find(options[:platform], game_identifier)
      if game.nil?
        shell.say "Game #{game_identifier} not found", :red
        return
      end
      puts "uninstalling game #{game.id} - #{game.name} - #{game.region} on #{options[:platform]} platform..."
      unless game.installed?
        shell.say 'Game is not installed', :yellow
        return
      end
      game.uninstall
      shell.say 'Game uninstalled', :green
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'uninstall_all', 'Uninstall all games'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    option :region, aliases: ['-g'], type: :string, required: false, desc: 'Only from specified region'
    def uninstall_all
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      games = repo.games options[:platform], region: options[:region]
      games.each do |game|
        uninstall(game.id) if game.installed?
      end
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'update_all_databases', 'Update all local databases'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    def update_all_databases
      puts "updating all databases on #{options[:repo]} repo..."
      repo = Repo.new(options[:repo])
      repo.platforms.each_key do |platform|
        repo = Repo.new(options[:repo])
        repo.update_database platform
      end
      shell.say 'All game databases updated', :green
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'update_database', 'Update local database'
    option :repo, aliases: ['-r'], type: :string, required: true, desc: 'Which repo to use', enum: Gamerom::Repo.list.map(&:to_s)
    option :platform, aliases: ['-p'], type: :string, required: true, desc: 'Which platform to use'
    def update_database
      repo = Repo.new(options[:repo])
      validate_platform repo, options[:platform]
      puts "updating #{options[:platform]} platform on #{options[:repo]} repo..."
      repo.update_database options[:platform]
      shell.say "Game database updated for platform #{options[:platform]} on #{options[:repo]} repo", :green
    rescue StandardError => e
      render_error e, options
      exit 1
    end

    desc 'version', 'Print program version'
    def version
      puts Gamerom::VERSION
    end

    private

    def print_game_table(games)
      results = games.map do |game|
        [
          game.id,
          game.name,
          game.region,
          game.installed? ? shell.set_color('installed', :green) : '-',
          game.respond_to?(:tags) ? game.tags.join(', ') : '-'
        ]
      end
      results.sort_by! { |columns| columns[1] }
      results.unshift %w[ID NAME REGION INSTALLED TAGS]
      shell.print_table(results)
    end

    def render_error(exception, options)
      shell.say exception.message, :red
      shell.say exception.full_message.force_encoding('utf-8'), :red if options[:verbose]
    end

    def validate_platform(repo, platform)
      return if repo.platforms.keys.include? options[:platform]

      raise "Expected '--platform' to be one of #{repo.platforms.keys.join(", ")}; got #{platform}"
    end
  end
end
