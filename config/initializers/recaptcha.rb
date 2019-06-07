Recaptcha.configure do |config|
  config.site_key  = Configuration.instance.recaptcha_public_key
  config.secret_key = Configuration.instance.recaptcha_secret_key
end
