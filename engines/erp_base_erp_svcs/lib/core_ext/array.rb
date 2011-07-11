Array.class_eval do

  #convert all elements of array to symbols
  #throw exception if all elements are not of class String
  def to_sym
    new_ary = []
    old_ary = to_ary

    old_ary.each do |item|
      if item.class == String
        new_ary << item.to_sym
      else
        throw "All array elements must be of class String to use to_sym"
      end
    end

    new_ary
  end

end
