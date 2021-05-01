# frozen_string_literal: true

require 'rom/platform'

require 'fileutils'
require 'nokogiri'
require 'rest-client'
require 'thor'
require 'yaml'

module Rom
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc 'list', 'List games'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to update", enum: Rom::PLATFORM.keys
    def list
      puts "listing avaiable games for #{options[:platform]} platform..."
      games = YAML.load_file(File.expand_path("~/.rom/cache/#{options[:platform]}.yml"))
      puts games.map { |game| "#{game[:id]} - #{game[:name]} - #{game[:region]}" }
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

    desc 'search', 'Search games'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to update", enum: Rom::PLATFORM.keys
    def search(keyword)
      puts "searching avaiable games for #{options[:platform]} platform..."
      games = YAML.load_file(File.expand_path("~/.rom/cache/#{options[:platform]}.yml"))
      games.each { |game|
        puts "#{game[:id]} - #{game[:name]} - #{game[:region]}" if game[:name] =~ /#{keyword}/i
      }
    rescue => e
      puts e.message
      exit 1
    end

    desc 'update', 'Update local database'
    option :platform, :aliases => ['-p'], type: :string, required: true, desc: "Which platform to update", enum: Rom::PLATFORM.keys
    option :v, type: :boolean, default: false, desc: "Show verbose backtrace"
    def update
      puts "updating #{options[:platform]} platform..."
      games = []
      letters = ('a'..'z').to_a.unshift("0")

      letters.each do |letter|
        print "#{letter} "
        page = Nokogiri::HTML(RestClient.get("https://coolrom.com.au/roms/psx/#{letter}/"))
        regions = page.css('input.region').map { |i| i["name"] }
        regions.each do |region|
          games.append *page.css("div.#{region} a").map { |game|
            {
              id: game['href'].split('/')[3].to_i,
              name: game.text,
              region: region,
            }
          }
        end
      end
      puts

      FileUtils.mkdir_p(File.expand_path("~/.rom/cache"))
      File.write(File.expand_path("~/.rom/cache/#{options[:platform]}.yml"), games.to_yaml)
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
