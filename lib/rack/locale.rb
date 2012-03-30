require 'ostruct'

module Rack
  class Locale
    def initialize(app)
      @app = app
    end

    def call(env)
      env["locale.language"] = parse_language(env)

      @app.call(env)
    end

    private
      def parse_language(env)
        language_ranges = env["HTTP_ACCEPT_LANGUAGE"].split(",")
        language_ranges.map do |language_range|
          language_range += ';q=1.0' unless language_range =~ /;q=\d+\.\d+$/

          locale, q = language_range.split(";q=")

          OpenStruct.new(:language => locale.strip, :q => q)
        end.sort {|x, y| y.q <=> x.q}.first.language
      end
  end
end
