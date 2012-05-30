require 'yaml'

class BasicConfig
  def initialize(hash)
    raise ArgumentError, 'Hash can not be nil' if hash.nil?

    # Symbolize keys: don't want to add ActiveSupport dependency just for this.
    @hash = hash.inject({}) do |h, (key, value)|
      h[key.to_sym] = value
      h
    end

    @hash.each do |key, value|
      @hash[key] = BasicConfig.new(value) if value.is_a?(Hash)
    end
  end

  def fetch(key)
    @hash.fetch(key)
  end

  def [](key)
    @hash[key]
  end

  def include?(key)
    @hash.has_key?(key)
  end

  def method_missing(meth, *args, &block)
    if include?(meth)
      raise ArgumentError, 'Getter can not receive any arguments' if !args.empty? || block_given?
      @hash[meth]
    else
      super
    end
  end

  def respond_to?(meth)
    include?(meth) or super
  end

  def to_hash
    @hash.dup.tap do |h|
      h.each do |key, value|
        h[key] = value.to_hash if value.is_a?(BasicConfig)
      end
    end
  end

  def self.load_file(name)
    BasicConfig.new(YAML.load_file(name))
  end

  def self.load_env(name, env)
    BasicConfig.new(YAML.load_file(name)[env])
  end
end
