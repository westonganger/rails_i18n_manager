Rails.application.configure do
  config.action_controller.allow_forgery_protection = false

  if Rails::VERSION::STRING.to_f >= 7.1
    config.action_dispatch.show_exceptions = :none
  else
    config.action_dispatch.show_exceptions = false
  end
end
