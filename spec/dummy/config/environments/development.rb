Rails.application.configure do
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.active_record.migration_error = :page_load
  config.consider_all_requests_local = true
  config.eager_load = true ### helps catch more errors in development
end
