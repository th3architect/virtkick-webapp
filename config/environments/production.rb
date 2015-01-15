class NoCompression
  def compress(string)
    # do nothing
    string
  end
end

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
#  if ENV['PRODUCTION_DEBUG']
    config.assets.compress = false
    config.assets.js_compressor = :uglifier
#  else
#    config.assets.compress = true
#    config.assets.js_compressor = :uglifier
#  end
  config.consider_all_requests_local = !! ENV['PRODUCTION_DEBUG']
  config.action_controller.perform_caching = true
  config.action_mailer.raise_delivery_errors = true # Will run in a background job, so users won't get a 500, but we will be notified by Bugsnag
  config.active_record.dump_schema_after_migration = false
#  config.assets.paths << Rails.root.join('app', 'assets', 'compiled_javascripts')
end
