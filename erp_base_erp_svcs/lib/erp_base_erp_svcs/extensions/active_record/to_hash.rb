ActiveRecord::Base.class_eval do

  #takes array of method names and returns hash with key/value pairs of methods
  def to_hash(*methods)
    {}.tap do |hash|
      methods.flatten.each do |method|
        if method.is_a?(Hash)
          hash[method.keys.first.to_sym] = method.values.first
        else
          method = method.to_sym
          hash[method] = self.send(method)
        end
      end
    end#end billing account hash tap
  end
end


