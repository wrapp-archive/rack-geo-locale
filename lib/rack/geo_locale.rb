require 'geoip'

module Rack
  class GeoLocale
    def initialize(app)
      @app = app
    end

    def call(env)
      env["locale.language"], env["locale.country"] = parse_locale(env)

      if country = parse_country(env)
        env["locale.country"] = country
      end

      @app.call(env)
    end

    private
      def parse_country(env)
        if database?
          if remote_addr = env["REMOTE_ADDR"]
            result = geoip.country(remote_addr).country_code2

            return result if result != "--"
          end
        end

        nil
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
        if ENV["GEOIP_DATABASE"]
          ::File.exist? ENV["GEOIP_DATABASE"]
        else
          false
        end
      end

      def database
        ENV["GEOIP_DATABASE"]
      end

      def geoip
        if database?
          GeoIP.new(database)
        else
          nil
        end
      end
  end
end
