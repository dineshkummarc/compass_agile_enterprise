module ErpBaseErpSvcs
	module Extensions
	  module Core
	    module Commas
	      def commas
    	    self.to_s =~ /([^\.]*)(\..*)?/
    	    int, dec = $1.reverse, $2 ? $2 : ""
    	    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
    	    end
    	    int.reverse + dec
    	  end
	    end
	  end
	end
end

class Bignum
	 include ErpBaseErpSvcs::Extensions::Core::Commas
end   

class Float
	 include ErpBaseErpSvcs::Extensions::Core::Commas
end

class Fixnum
	 include ErpBaseErpSvcs::Extensions::Core::Commas
end