require 'bundler/setup'
Bundler.require

class MySinatra
  class Base
    def call(env)
      verb = env["REQUEST_METHOD"]
      path = env["REQUEST_PATH"]
      response_for("#{verb} #{path}")
    end

    def get(path, &block)
      add_handler("GET #{path}", block)
    end

    def post(path, &block)
      add_handler("POST #{path}", block)
    end

    def add_handler(verb_and_path, block)
      handlers[verb_and_path] = block
    end

    def response_for(verb_and_path)
      if handlers.key?(verb_and_path)
        handlers[verb_and_path].call
      else
        default_response
      end
    end

    def default_response
      body = <<-EOHTML
        <!DOCTYPE html>
        <html>
          <body>
            <h1>That route doesn't exist :(</h1>
          </body>
        </html>
      EOHTML
      [404, {"Content-Type" => "text/html"}, body]
    end

    def handlers
      @handlers ||= {}
    end
  end
end

app = MySinatra::Base.new
app.get "/hello" do
  [200, {"Content-Type" => "text/html"}, "Hi there!"]
end

app.post "/hello" do
  [200, {"Content-Type" => "text/html"}, "You POSTed to /hello"]
end

Rack::Handler::Thin.run app, Port: 4567
