assets = Rails.application.config.assets
assets.precompile += %w(views/guests/index.js)
assets.precompile += %w(views/machine/index.js)
assets.precompile += %w(views/machine/new.js)
assets.precompile += %w(views/machine/show.js)
