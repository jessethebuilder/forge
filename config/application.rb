require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Forge
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    config.action_mailer.default_url_options = {host: ENV.fetch('EMAIL_HOST')}
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.perform_deliveries = true
    config.action_mailer.default :charset => 'utf-8'

    config.action_mailer.smtp_settings = {
      :address => ENV.fetch('EMAIL_ACCOUNT'),
      :port => ENV.fetch('EMAIL_PORT'),
      :domain => ENV.fetch('EMAIL_DOMAIN'),
      :authentication => 'plain',
      :user_name => ENV.fetch('EMAIL_USER'),
      :password => ENV.fetch('EMAIL_PASSWORD'),

      :enable_starttls_auto => true,
      :openssl_verify_mode => 'none'
    }

    config.stripe_secret_key = ENV.fetch('STRIPE_SECRET')
    config.stripe_publishable_key = ENV.fetch('STRIPE_KEY')
  end
end
