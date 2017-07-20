require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Psap
  class Application < Rails::Application

    config.after_initialize do
      ActiveRecord::Base.logger = nil
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += %W(#{config.root}/app/commands)
    config.autoload_paths += %W(#{config.root}/app/errors)

    config.assets.paths << "#{Rails.root}/app/assets/collection_id_guide"
    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.i18n.enforce_available_locales = true

    # Set up ActionMailer
    require File.expand_path('app/models/configuration.rb')
    yml = ::Configuration.instance
    config.action_mailer.default_options = { from: yml.mail_from }
    config.action_mailer.delivery_method = yml.mail_delivery_method.to_sym
    config.action_mailer.smtp_settings = {
        openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
    config.action_mailer.smtp_settings[:address] = yml.mail_smtp_host if
        yml.mail_smtp_host
    config.action_mailer.smtp_settings[:port] = yml.mail_smtp_port if
        yml.mail_smtp_port
    config.action_mailer.smtp_settings[:user_name] = yml.mail_username if
        yml.mail_username
    config.action_mailer.smtp_settings[:password] = yml.mail_password if
        yml.mail_password
    config.action_mailer.smtp_settings[:authentication] = yml.mail_authentication if
        yml.mail_authentication
    config.action_mailer.smtp_settings[:enable_starttls_auto] = yml.mail_enable_starttls_auto if
        yml.mail_enable_starttls_auto
  end
end
