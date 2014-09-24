require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Psap
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += %W(#{config.root}/app/commands)
    config.autoload_paths += %W(#{config.root}/app/errors)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.i18n.enforce_available_locales = true

    # Set up ActionMailer
    mail_config_path = "#{Rails.root}/config/mail.yml"
    if File.exist?(mail_config_path)
      mail_config = YAML.load_file(mail_config_path)[Rails.env]

      config.action_mailer.default_options = { from: mail_config['from'] }
      config.action_mailer.delivery_method = mail_config['delivery_method'].to_s
      config.action_mailer.smtp_settings = {}
      config.action_mailer.smtp_settings[:address] = mail_config['smtp_host'] if
          mail_config['smtp_host']
      config.action_mailer.smtp_settings[:port] = mail_config['smtp_port'] if
          mail_config['smtp_port']
      config.action_mailer.smtp_settings[:user_name] = mail_config['username'] if
          mail_config['username']
      config.action_mailer.smtp_settings[:password] = mail_config['password'] if
          mail_config['password']
      config.action_mailer.smtp_settings[:authentication] = mail_config['authentication'] if
          mail_config['authentication']
      config.action_mailer.smtp_settings[:enable_starttls_auto] = mail_config['enable_starttls_auto'] if
          mail_config['enable_starttls_auto']

      config.psap_email_address = mail_config['address']
    end
  end
end
