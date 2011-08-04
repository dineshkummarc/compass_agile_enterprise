module TechServices::Sessions
require 'tech_services/utils/compass_logger'

  # Delayed Job to Reset Daily Assignments to Forecast
  class DeleteExpiredSessionsJob  

    def initialize
      @priority = 1
    end
  
    def perform
      begin
        process_job
      rescue => exception
        CompassLogger.delete_expired_sessions_job.error("An unrecoverable error has occured, the job will be rescheduled: #{exception.message} : #{exception.backtrace}")
      end
    
      # Run once per day
      date = Date.tomorrow
      start_time = DateTime.civil(date.year, date.month, date.day, 2, 0, 1, -(5.0/24.0))
    
      Delayed::Job.enqueue(DeleteExpiredSessionsJob.new(), @priority, start_time)
    end

    def self.schedule_job(schedule_dt)
      Delayed::Job.enqueue(DeleteExpiredSessionsJob.new(), @priority, schedule_dt)
    end

    def process_job
      start_time = Time.now
    
      TechServices::Sessions::DeleteExpiredSessionsService.new.execute
    
      end_time = Time.now
    
      return end_time - start_time
    end
  
  end #Close Class
  
end #Close Module
