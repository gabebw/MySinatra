require 'bundler/setup'
Bundler.require

class MySinatra
  class Base
    def self.call(env)
      verb = env["REQUEST_METHOD"]
      path = env["REQUEST_PATH"]
      get_handler("#{verb} #{path}")
    end

    def self.get(path, &block)
      add_handler("GET #{path}", block)
    end

    def self.add_handler(verb_and_path, block)
      @handlers ||= {}
      @handlers[verb_and_path] = block
    end

    def self.get_handler(verb_and_path)
      if @handlers.key?(verb_and_path)
        @handlers[verb_and_path].call
      else
        unless path = '/favicon.ico'
          raise "No handler for #{verb_and_path}"
        end
      end
    end
  end
end

class App < MySinatra::Base
  get "/hello" do
    [200, {"Content-Type" => "text/html"}, "Hi there!"]
  end
end

Rack::Handler::Thin.run App, Port: 4567
