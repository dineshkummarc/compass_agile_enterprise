module TechServices::Sessions
  class DeleteExpiredSessionsService

    def initialize
      @session_age = 12.hours
    end
    
    def execute
      ActiveRecord::SessionStore::Session.delete_all ['updated_at < ?', @session_age.ago] 
    end
    
  end
end