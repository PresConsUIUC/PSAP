Recaptcha.configure do |config|
  config.public_key  = Psap::Application.psap_config[:recaptcha][:public_key]
  config.private_key = Psap::Application.psap_config[:recaptcha][:secret_key]
end
