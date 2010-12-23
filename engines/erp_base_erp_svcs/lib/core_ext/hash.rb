Hash.class_eval do
  #take keys of hash and transform those to a symbols
  def self.symbolize_keys(item)
    if item.class == Hash
      item.to_options!
      item.each do |key, value|
        self.symbolize_keys(value)
      end
    elsif item.class == Array
      item.each do |array_val|
        self.symbolize_keys(array_val)
      end
    end

    item
  end

end

