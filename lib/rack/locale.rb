require 'ostruct'

module Rack
  class Locale
    def initialize(app)
      @app = app
    end

    def call(env)
      env["locale.languages"] = parse_languages(env)

      @app.call(env)
    end

    private
      def parse_languages(env)
        language_ranges = env["HTTP_ACCEPT_LANGUAGE"].split(",")
        language_ranges.map do |language_range|
          language_range += ';q=1.0' unless language_range =~ /;q=\d+\.\d+$/

          locale, q = language_range.split(";q=")

          language = locale.strip.split("-").first

          OpenStruct.new(:language => language, :q => q)
        end.sort {|x, y| y.q <=> x.q}.map{|lr| lr.language}
      end
  end
end
