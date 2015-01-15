assets = Rails.application.config.assets
assets.precompile += %w(pages/*.js)
Rack::Mime::MIME_TYPES.merge!({".map" => "text/plain"})

