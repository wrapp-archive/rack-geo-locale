require 'rack/test'
require 'rack/locale'

include Rack::Test::Methods

def app
  Rack::Locale.new(proc {|env| [200, {}, 'hello']})
end

describe Rack::Locale do
  it "should respond with hello" do
    get '/'
    last_response.body.should == "hello"
  end
end
