
FBT = ConfigUtils::Config.load_file(
    Rails.root.join('config', 'feature_bits.yml'),
    Rails.env
)