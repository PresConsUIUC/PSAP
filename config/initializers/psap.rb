Psap::Application.psap_config =
    YAML.load_file(File.join(Rails.root, 'config', 'psap.yml'))[Rails.env]