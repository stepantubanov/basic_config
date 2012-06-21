require 'yaml'

class BasicConfig
  class NotFound < RuntimeError
    attr_reader :name, :scope, :key

    def initialize(name, scope, key)
      @name = name
      @scope = scope
      @key = key

      super("Configuration key '#{scope}#{key}' is missing in #{name}")
    end
  end

  def initialize(hash, configuration_name = nil, configuration_scope = '')
    raise ArgumentError, 'Hash can not be nil' if hash.nil?

    @name = configuration_name || "BasicConfig constructed at #{caller[0]}"
    @scope = configuration_scope

    # Symbolize keys: don't want to add ActiveSupport dependency just for this.
    @hash = hash.inject({}) do |h, (key, value)|
      h[key.to_sym] = value
      h
    end

    @hash.each do |key, value|
      @hash[key] = BasicConfig.new(value, @name, [@scope, key, '.'].join) if value.is_a?(Hash)
    end
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
      raise NotFound.new(@name, @scope, meth)
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
    BasicConfig.new(YAML.load_file(name), name)
  end

  def self.load_env(name, env)
    BasicConfig.new(YAML.load_file(name)[env], name, env + '.')
  end
end
