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
        env["HTTP_ACCEPT_LANGUAGE"]
      end
  end
end
