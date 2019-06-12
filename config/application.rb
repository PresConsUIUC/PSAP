require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Psap
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set up ActionMailer
    require File.expand_path('app/models/configuration.rb')
    yml = ::Configuration.instance
    config.action_mailer.default_options = { from: yml.mail_from }
    config.action_mailer.delivery_method = yml.mail_delivery_method.to_sym
    config.action_mailer.smtp_settings   = {
        openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
    config.action_mailer.smtp_settings[:address]              = yml.mail_smtp_host if yml.mail_smtp_host
    config.action_mailer.smtp_settings[:port]                 = yml.mail_smtp_port if yml.mail_smtp_port
    config.action_mailer.smtp_settings[:user_name]            = yml.mail_username if yml.mail_username
    config.action_mailer.smtp_settings[:password]             = yml.mail_password if yml.mail_password
    config.action_mailer.smtp_settings[:authentication]       = yml.mail_authentication if yml.mail_authentication
    config.action_mailer.smtp_settings[:enable_starttls_auto] = yml.mail_enable_starttls_auto if yml.mail_enable_starttls_auto
  end
end
