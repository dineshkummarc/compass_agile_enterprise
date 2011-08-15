module RailsDbAdmin
	class ConnectionHandler
  
	  def self.create_connection_class(database)
	      klass = nil
	
	      unless database.blank?
	        klass = Class.new ActiveRecord::Base
	        klass.establish_connection(database)
	      else
	        klass = ActiveRecord::Base
	      end
	      
	      klass
	  end
  end
end

