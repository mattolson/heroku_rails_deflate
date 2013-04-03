# heroku\_rails\_deflate

The Heroku Cedar stack is not fronted by an asset server such as Varnish or nginx, and there is no automatic provision
for using gzip compression for HTTP transfers. At the same time, the Rails 3.2 asset pipeline spends a lot
of CPU cycles creating highly compressed versions of all our static assets. It would be great to use them!

This gem activates Rack::Deflate for all requests. But the real coolness is the custom middleware that checks
for the .gz version of precompiled assets and serves them up for you. We also eliminate conflict with Rack::Deflate
by telling it not to compress these already compressed files. We also provide a sensible default for the Cache-Control
header for these files. If you are using the asset digest in the filename (and you should), there is no reason
why we can't set very high max-age, so we set it to one year by default.

You should see a nice performance boost from the installation of this gem, without any additional work on your
part. After you get done with this, you could take it to the next level by adding a CDN such as AWS CloudFront.

## Installation

* Add the gem to your app

    gem 'heroku_rails_deflate', :group => :production

* Make sure asset caching is configured correctly in environments/production.rb:

    config.serve_static_assets = true
    config.assets.compress = true
    config.assets.compile = true
    config.assets.digest = true

* If you want a different max-age for your static assets, you can override the default:

    config.static_cache_control = "public, max-age=31536000"

* You should precompile your assets prior to deploying to Heroku to save CPU cycles at request time:

    RAILS_ENV=production rake assets:precompile


## Contributing to heroku\_rails\_deflate
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Thanks

This gem expands on code originally published in a [gist](https://gist.github.com/guyboltonking/2152663) by [guyboltonking](https://github.com/guyboltonking). 

## Copyright

Copyright (c) 2013 Matt Olson. See LICENSE.txt for further details.

