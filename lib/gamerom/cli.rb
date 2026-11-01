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
    rescue Gamerom::ManualDownloadRequired => e
      shell.say e.message, :yellow
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
        if game.installed?
          shell.say "Game #{game.name} already installed", :yellow
          next
        end
        install(game.id)
      rescue StandardError, SystemExit => e
        shell.say "Error installing game #{game.name}: #{e.message}", :red
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
      game_names = games.to_h { |game| [game.id, game.name] }
      results = games.group_by { |game| recover_game(game, game_names) }

      print_recover_summary(results.fetch(:found, []), results.fetch(:already_installed, []), results.fetch(:not_found, []))
    rescue StandardError => e
      render_error e, options
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
      failed = repo.platforms.keys.reject do |platform|
        repo.update_database platform
        true
      rescue StandardError => e
        shell.say "Error updating #{platform}: #{e.message}", :red
        false
      end
      if failed.empty?
        shell.say 'All game databases updated', :green
      else
        shell.say "Failed to update: #{failed.join(", ")}", :red
        exit 1
      end
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

    # Recover helpers

    def recover_game(game, game_names)
      puts
      puts "Checking game #{game}"
      if game.filenames.any?
        puts "#{shell.set_color("*", :green)} Found game at: #{game.filenames.first}"
        return :already_installed
      end

      game_files = glob_game_files(game).select { |file| file_belongs_to_game?(file, game, game_names) }.sort
      if game_files.empty?
        puts "#{shell.set_color("*", :red)} not found"
        return :not_found
      end

      game.update_state(game_files.map { |file| File.basename(file) })
      print_recovered_files(game_files)
      :found
    end

    def glob_game_files(game)
      patterns = [
        glob_escape(game.name.tr(' ', '_'), '_'),
        glob_escape(game.name, ' ')
      ]
      patterns.flat_map { |pattern| Dir.glob("#{game.filepath}/#{pattern}*") }.uniq
    end

    def glob_escape(str, spacer)
      str
        .gsub(/([\\\[\]*?{}) ,])/, '\\\\\1')
        .gsub(':', "#{spacer}-")
        .gsub('!', '\!*')
        .gsub('(', '*\(')
    end

    # A globbed file is kept for a game unless it is a better match for another
    # game whose name starts with this game's name (e.g. "Kung-Fu" vs "Kung-Fu Master").
    def file_belongs_to_game?(file, game, game_names)
      filename = File.basename(file).downcase
      return true if exact_filename_match?(filename, game.name.downcase)

      number = sequel_number(game.name)
      return true if number && filename.include?(number)
      return true if game.name.include?('Limited Run Games') && filename.include?('limited_run')

      !claimed_by_other_game?(filename, game, game_names)
    end

    # "Game.zip", "Game_Name.zip" or "Game (USA).zip"
    def exact_filename_match?(filename, name)
      [name, name.tr(' ', '_')].any? do |variant|
        filename.match?(/\A#{Regexp.escape(variant)}(\s*\(\w+\))?\.\w+\z/i)
      end
    end

    # The number that identifies a sequel, e.g. "2" in "Tony Hawk's Pro Skater 2"
    def sequel_number(name)
      match = name.match(/(\d+|\s+\d+)[\s':]/) || name.match(/\s(\d+)$/)
      match && match[1].strip
    end

    def claimed_by_other_game?(filename, game, game_names)
      name = game.name.downcase
      game_names.any? do |other_id, other_name|
        next false if other_id == game.id

        other = other_name.downcase
        next false unless other.length > name.length && other.start_with?(name)

        filename_matches_other_game?(filename, other_name)
      end
    end

    def filename_matches_other_game?(filename, other_name)
      other = other_name.downcase
      other_underscored = other.tr(' ', '_')
      return false unless filename.include?(other_underscored) || filename.include?(other)

      number = sequel_number(other_name)
      return filename.include?(number) if number

      filename.start_with?(other_underscored) ||
        filename.start_with?(other) ||
        filename.include?(other_underscored.tr(':', '_')) ||
        filename.include?(other.tr(':', '-'))
    end

    def print_recovered_files(game_files)
      if game_files.size > 1
        puts "#{shell.set_color("*", :green)} Found #{game_files.size} disks for game:"
        game_files.each { |file| puts "  - #{file}" }
      else
        puts "#{shell.set_color("*", :green)} Found game at: #{game_files.first}"
      end
    end

    def print_recover_summary(games_found, games_already_installed, games_not_found)
      if games_not_found.empty?
        puts "All #{games_found.count + games_already_installed.count} games found"
      else
        puts "#{shell.set_color(games_found.count, :green)} games found"
        puts "#{shell.set_color(games_already_installed.count, :yellow)} games already installed"
        puts "#{shell.set_color(games_not_found.count, :red)} games not found"
      end
    end
  end
end
