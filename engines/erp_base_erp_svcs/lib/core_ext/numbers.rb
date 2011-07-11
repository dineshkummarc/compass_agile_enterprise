class Bignum
	 
	  def commas
	    self.to_s =~ /([^\.]*)(\..*)?/
	    int, dec = $1.reverse, $2 ? $2 : ""
	    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
	    end
	    int.reverse + dec
	  end
	 
	end   
	 
	class Float
	 
	  def commas
	    self.to_s =~ /([^\.]*)(\..*)?/
	    int, dec = $1.reverse, $2 ? $2 : ""
	    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
	    end
	    int.reverse + dec
	  end
	 
	end
	 
	class Fixnum
	 
	  def commas
	    self.to_s =~ /([^\.]*)(\..*)?/
	    int, dec = $1.reverse, $2 ? $2 : ""
	    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
	    end
	    int.reverse + dec
	  end
	 
	end