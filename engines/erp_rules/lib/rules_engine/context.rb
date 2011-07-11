class RulesEngine::Context
  attr_accessor :values_hash

  def initialize
    self.values_hash = {}
  end

  def [](key)
    self.values_hash[key]
  end

  def []=(key, *args)
    self.values_hash[key] = args[0]
  end

  def method_missing(name, *args)
    setter = nil
    if(name.to_s.include?('='))
      name = name.to_s.split('=')[0]
      setter = true
      name = name.to_sym
    end

    if setter
      self.values_hash[name] = args[0]
      return self
    elsif self.values_hash.has_key?(name)
      return self.values_hash[name]
    else
      super
    end
  end

end