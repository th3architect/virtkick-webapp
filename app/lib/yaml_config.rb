require 'active_support/hash_with_indifferent_access'

# TODO: autoreload YAML files in development
class YamlConfig
  def initialize config_name
    config_file = File.join Rails.root, 'config', "#{config_name}.yml"
    yaml = ERB.new(File.read(config_file)).result
    config = YAML.load(yaml)[Rails.env]

    @config = if config.is_a? Array
      config.map &:deep_symbolize_keys
    else
      config.deep_symbolize_keys
    end
  end

  def method_missing method, *args
    @config.public_send method, *args
  end
end
