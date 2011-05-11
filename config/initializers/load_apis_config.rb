
C = ConfigUtils::Config.load_file(
  Rails.root.join('config', 'apis.yml'),
  Rails.env
)