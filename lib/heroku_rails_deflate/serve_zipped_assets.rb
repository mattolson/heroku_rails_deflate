require 'action_controller'
require 'active_support/core_ext/uri'
require 'action_dispatch/middleware/static'

# Middleware to serve the gzipped version of static assets if they exist
# Adapted from https://gist.github.com/guyboltonking/2152663
module HerokuRailsDeflate
  class ServeZippedAssets
    # Params:
    #   root: the public directory
    #   asset_prefix: config.assets.prefix
    #   cache_control: config.static_cache_control
    def initialize(app, root, asset_prefix, cache_control=nil)
      @app = app
      @asset_prefix = asset_prefix.chomp('/') + '/'
      @file_handler = ActionDispatch::FileHandler.new(root, headers: { "Cache-Control" => cache_control })
    end

    def call(env)
      # Only process get requests
      if env['REQUEST_METHOD'] == 'GET'
        request = Rack::Request.new(env)

        # See if client accepts gzip encoding
        if Rack::Utils.select_best_encoding(%w(gzip identity), request.accept_encoding) == 'gzip'
          # Check if compressed version exists in assets directory
          compressed_path = env['PATH_INFO'] + '.gz'
          if compressed_path.start_with?(@asset_prefix) && (match = @file_handler.match?(compressed_path))
            # Use FileHandler to serve up the gzipped file, then strip the .gz suffix
            path = env["PATH_INFO"] = match
            status, headers, body = @file_handler.call(env)
            path = env["PATH_INFO"] = env["PATH_INFO"].chomp('.gz')

            # Set the Vary HTTP header.
            vary = headers["Vary"].to_s.split(",").map(&:strip)
            unless vary.include?("*") || vary.include?("Accept-Encoding")
              headers["Vary"] = vary.push("Accept-Encoding").join(",")
            end

            # Add encoding and type
            headers['Content-Encoding'] = 'gzip'
            headers['Content-Type'] = Rack::Mime.mime_type(File.extname(path), 'text/plain')

            # Update cache-control to add directive telling Rack::Deflate to leave it alone.
            cache_control = headers['Cache-Control']&.to_s&.downcase
            if cache_control.nil?
              headers['Cache-Control'] = 'no-transform'
            elsif !cache_control.include?('no-transform')
              headers['Cache-Control'] += ', no-transform'
            end

            body.close if body.respond_to?(:close)
            return [status, headers, body]
          end
        end
      end

      @app.call(env)
    end
  end
end
