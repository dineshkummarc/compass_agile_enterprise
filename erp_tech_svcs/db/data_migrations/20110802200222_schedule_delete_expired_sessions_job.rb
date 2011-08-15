class ScheduleDeleteExpiredSessionsJob
  
  def self.up
    #insert data here
    date = Date.tomorrow
    start_time = DateTime.civil(date.year, date.month, date.day, 2, 0, 1, -(5.0/24.0))

    TechServices::Sessions::DeleteExpiredSessionsJob.schedule_job(start_time)
  end
  
  def self.down
    #remove data here
  end

end
