require 'geoip'
require 'open-uri'

module Rack
  class GeoLocale
    DATABASE = "tmp/geoip_database.dat"

    def initialize(app)
      @geoip = fetch_database

      @app = app
    end

    def call(env)
      language, country = parse_locale(env)

      if c = parse_country(env)
        country = c
      end

      language.downcase! if language
      country.upcase! if country

      env["locale.language"] = language
      env["locale.country"] = country

      @app.call(env)
    end

    private
      def parse_country(env)
        if database?
          if addr = env["REMOTE_ADDR"]
            addr = env["HTTP_X_FORWARDED_FOR"] if env["HTTP_X_FORWARDED_FOR"]
            addr = addr.split(",").first.strip

            # puts "INFO: Trying to lookup #{addr}"

            result = '--'
            country = @geoip.country(addr)
            if country
              result = country.country_code2
            end

            if result != "--"
              # puts "INFO: Found country for #{addr} #{result}"

              result
            else
              # puts "INFO: Didn't find country for #{addr}"
            end
          else
            puts "WARNING: Didn't find env['REMOTE_ADDR']"
          end
        else
          puts "WARNING: Didn't find geoip database."
        end
      end

      def parse_locale(env)
        env["HTTP_ACCEPT_LANGUAGE"] ||= ""
        language_ranges = env["HTTP_ACCEPT_LANGUAGE"].split(",")
        language_ranges.map do |language_range|
          language_range += ';q=1.0' unless language_range =~ /;q=\d+\.\d+$/

          locale, q = language_range.split(";q=")

          language, country = locale.strip.split("-")

          {:language => language, :country => country, :q => q}
        end.sort {|x, y| y[:q] <=> x[:q]}.map{|o| [o[:language], o[:country]]}.first
      end

      def database?
        @geoip != nil
      end

      def fetch_database
        if ENV["GEOIP_DATABASE_URI"]
          puts "-> Fetching #{ENV["GEOIP_DATABASE_URI"]}"

          `curl --silent -o #{DATABASE}.gz #{ENV["GEOIP_DATABASE_URI"]}`
          `gunzip -f #{DATABASE}.gz`

          GeoIP.new(DATABASE)
        else
          puts "WARNING: Set the ENV['GEOIP_DATABASE_URI'] to the location of your .gz database file."

          nil
        end
      end
  end
end
