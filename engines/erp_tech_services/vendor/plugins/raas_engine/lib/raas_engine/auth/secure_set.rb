class RaasEngine::Auth::SecureSet

  def initialize(subject, which)
    @subject = subject
    @which = which
    @elements = []
  end

  def add_all(set)
    @elements.push(set).flatten!
  end

  def type_equals(type)
    results = []
    @elements.each do |element|
      if element.class.to_s.downcase == type.downcase
        results << element
      end
    end
    results
  end

  def contains?(obj)
    @elements.each do |element|
      if element == obj
        return true
      end
    end
    return false
  end

  def size()
    return @elements.size
  end

  def clear()
    @elements.clear()
  end

  def remove(element)
    @elements.delete(element)
  end

  alias_method :remove_all, :clear

end