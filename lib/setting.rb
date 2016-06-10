module Setting
  def self.config
    @@settings ||= self.load_settings
  end
  
  def self.load_settings
    config_file = File.join(File.dirname(File.expand_path(__FILE__)), '..', 'config', 'config.yml')
    File.exists?(config_file) ? YAML::load_file(config_file) : {}
  end
end