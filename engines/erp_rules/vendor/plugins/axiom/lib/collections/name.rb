# module containing a name accessor mutator pair

module Collections::Name
  def name=(new_name)
    @name=new_name
  end

  def name()
    return @name
  end
end
