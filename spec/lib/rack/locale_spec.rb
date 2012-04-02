require 'rack/test'
require 'rack/locale'
require 'geoip'

include Rack::Test::Methods

def app
  Rack::Locale.new(proc {|env| [200, {}, 'hello']})
end

describe Rack::Locale do
  describe "GeoIP" do
    before do
      geoip = double("geoip")
      geoip.stub(:country).with("10.0.0.1").and_return("foo")

      GeoIP.stub :new => geoip
    end

    it "should stub correctly" do
      GeoIP.new.country("10.0.0.1").should == "foo"
    end

    xit "should set the REMOTE_ADDR header" do
      get '/', {}, {"REMOTE_ADDR" => "10.0.0.1"}
      last_request.env["locale.country"].should == ["us"]
      last_request.ip.should == "10.0.0.1"
    end
  end

  describe "parsing HTTP_ACCEPT_LANGUAGE" do
    it "should return an empty result if no HTTP_ACCEPT_LANGUAGE passed" do
      get '/', {}, {}
      last_request.env["locale.languages"].should == []
    end

    it "should parse HTTP_ACCEPT_LANGUAGE 'en'" do
      get '/', {}, {"HTTP_ACCEPT_LANGUAGE" => "en"}
      last_request.env["locale.languages"].should == ["en"]
    end

    it "should parse HTTP_ACCEPT_LANGUAGE 'sv'" do
      get '/', {}, {"HTTP_ACCEPT_LANGUAGE" => "sv"}
      last_request.env["locale.languages"].should == ["sv"]
    end

    it "should parse HTTP_ACCEPT_LANGUAGE 'sv;q=0.1, en'" do
      get '/', {}, {"HTTP_ACCEPT_LANGUAGE" => "sv;q=0.1, en"}
      last_request.env["locale.languages"].should == ["en", "sv"]
    end

    it "should parse HTTP_ACCEPT_LANGUAGE 'sv, en'" do
      get '/', {}, {"HTTP_ACCEPT_LANGUAGE" => "sv, en"}
      last_request.env["locale.languages"].should == ["sv", "en"]
    end

    it "should parse HTTP_ACCEPT_LANGUAGE 'en;q=0.4, de;q=0.7'" do
      get '/', {}, {"HTTP_ACCEPT_LANGUAGE" => "en;q=0.4, de;q=0.7"}
      last_request.env["locale.languages"].should == ["de", "en"]
    end

    it "should parse HTTP_ACCEPT_LANGUAGE 'en-US;q=0.7'" do
      get '/', {}, {"HTTP_ACCEPT_LANGUAGE" => "en-US;q=0.7"}
      last_request.env["locale.languages"].should == ["en"]
    end
  end
end
