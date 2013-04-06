require 'rack/mock'
require 'rack/static'
require 'timecop'
require 'heroku_rails_deflate/serve_zipped_assets'

# Return a bogus response so we can detect rack passthrough
class MockServer
  def initialize; end
  def call(env)
    Rack::MockResponse.new(500, {'X-mock' => 'mocked!'}, 'ERROR')
  end
end

describe HerokuRailsDeflate::ServeZippedAssets do
  def process(path, cache_control='public, max-age=31536000')
    root_path = File.expand_path('../fixtures', __FILE__)
    request_env = Rack::MockRequest.env_for(path)
    request_env['HTTP_ACCEPT_ENCODING'] = 'compress, gzip, deflate'

    deflate_server = described_class.new(MockServer.new, root_path, '/assets', cache_control)
    deflate_server.call(request_env)
  end

  it "has correct content encoding" do
    status, headers, body = process('/assets/bender.jpg')
    status.should eq(200)
    headers['Content-Encoding'].should eq('gzip')
  end

  it "has correct cache-control header" do
    status, headers, body = process('/assets/bender.jpg')
    status.should eq(200)
    headers['Cache-Control'].should eq('public, max-age=31536000, no-transform')
  end

  it "should not modify existing cache-control header" do
    status, headers, body = process('/assets/bender.jpg', 'private')
    status.should eq(200)
    headers['Cache-Control'].should eq('private, no-transform')
  end

  it "should create cache-control header if necessary" do
    status, headers, body = process('/assets/bender.jpg', nil)
    status.should eq(200)
    headers['Cache-Control'].should eq('no-transform')
  end

  it "should add expires header set to five years from now" do
    Timecop.freeze(Time.utc(2013,4,6,13,35,59)) do
      status, headers, body = process('/assets/bender.jpg', nil)
      status.should eq(200)
      headers['Expires'].should eq('Thu, 05 Apr 2018 13:35:59 GMT')
    end
  end

  it "should not serve anything from non-asset directories" do
    status, headers, body = process('/non-asset/bender.jpg', nil)
    headers['X-mock'].should eq('mocked!')
  end
end
