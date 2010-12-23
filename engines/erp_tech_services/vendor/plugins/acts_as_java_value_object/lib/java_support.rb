# provides java support methods

module JavaSupport
  # helper method to create a standard java
  # mutator name from a snake_cased string
  def create_java_mutator_name(str)
    return "set"+camel_case(str)
  end

  # helper method to create a standard java
  # accessor name from a snake_cased string
  def create_java_accessor_name(str)
    return "get"+camel_case(str)
  end

  # convert a snake_case string to CamelCase
  def camel_case(str)
    return str if str !~ /_/ && str =~ /[A-Z]+.*/
    retval=""
    str.split('_').map do |i|
      d=i.capitalize

      retval<< d

    end
    return retval
  end
end
