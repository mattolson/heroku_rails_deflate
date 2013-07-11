require 'action_controller'
require 'active_support/core_ext/uri'
require 'action_dispatch/middleware/static'

# Adapted from https://gist.github.com/guyboltonking/2152663
module HerokuRailsDeflate
  class ServeZippedAssets
    def initialize(app, root, assets_path, cache_control=nil)
      @app = app
      @assets_path = assets_path.chomp('/') + '/'
      @file_handler = ActionDispatch::FileHandler.new(root, cache_control)
    end

    def call(env)
      if env['REQUEST_METHOD'] == 'GET'
        request = Rack::Request.new(env)
        encoding = Rack::Utils.select_best_encoding(%w(gzip identity), request.accept_encoding)

        if encoding == 'gzip'
          # See if gzipped version exists in assets directory
          compressed_path = env['PATH_INFO'] + '.gz'
          if compressed_path.start_with?(@assets_path) && (match = @file_handler.match?(compressed_path))
            # Get the FileHandler to serve up the gzipped file, then strip the .gz suffix
            env["PATH_INFO"] = match
            status, headers, body = @file_handler.call(env)
            path = env["PATH_INFO"] = env["PATH_INFO"].chomp('.gz')

            # Set the Vary HTTP header.
            vary = headers["Vary"].to_s.split(",").map { |v| v.strip }
            unless vary.include?("*") || vary.include?("Accept-Encoding")
              headers["Vary"] = vary.push("Accept-Encoding").join(",")
            end

            # Add encoding and type
            headers['Content-Encoding'] = 'gzip'
            headers['Content-Type'] = Rack::Mime.mime_type(File.extname(path), 'text/plain')
            headers.delete('Content-Length')

            # Update cache-control to add directive telling Rack::Deflate to leave it alone.
            cache_control = headers['Cache-Control'].try(:to_s).try(:downcase)
            if cache_control.nil?
              headers['Cache-Control'] = 'no-transform'
            elsif !cache_control.include?('no-transform')
              headers['Cache-Control'] += ', no-transform'
            end

            return [status, headers, body]
          end
        end
      end

      status, headers, body = @app.call(env)
      body.close if body.respond_to?(:close)
      [status, headers, body]
    end
  end
end
