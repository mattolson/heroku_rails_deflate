require 'rack/deflater'
require 'heroku_rails_deflate/serve_zipped_assets'

module HerokuRailsDeflate
  class Railtie < Rails::Railtie
    # Use after_initialize to ensure that all other middleware is already loaded
    initializer "heroku_rails_deflate.middleware_initialization", :after => :load_config_initializers do |app|
      # Put Rack::Deflater in the right place
      if app.config.action_controller.perform_caching && app.config.action_dispatch.rack_cache
        app.config.middleware.insert_after 'Rack::Cache', 'Rack::Deflater'
      else
        app.config.middleware.insert_before 'ActionDispatch::Static', 'Rack::Deflater'
      end

      # Insert our custom middleware for serving gzipped static assets
      app.config.middleware.insert_after 'Rack::Deflater', 'HerokuRailsDeflate::ServeZippedAssets', app.paths["public"].first, app.config.assets.prefix, app.config.static_cache_control
    end

    # Set default Cache-Control headers to 365 days. Override in config/application.rb.
    config.before_configuration do |app|
      app.config.static_cache_control = 'public, max-age=31536000'
    end
  end
end
