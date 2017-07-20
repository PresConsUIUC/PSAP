Recaptcha.configure do |config|
  config.public_key  = Configuration.instance.recaptcha_public_key
  config.private_key = Configuration.instance.recaptcha_secret_key
end
