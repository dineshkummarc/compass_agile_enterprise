module TechServices::Utils::Chucky
  def thread_safe(seconds = 10, &block)
    begin
      load_queue(block)
      monitor_queue(seconds)
    rescue Timeout::Error
      sleep(10)
      puts "Retry..............."
      @queue.pop
      load_queue(block)
      monitor_queue(seconds)
    rescue Exception
      puts "Re-raise"
      raise "Failed"
    end
  end

  def load_queue(block)
    @queue = []
    @queue << Thread.new {
      block.call
      @queue.pop
    }
  end

  def monitor_queue(seconds)
    Timeout.timeout(seconds) {
      begin
        while !@queue.empty?
        end
      ensure
      end
    }
  end

  extend self
end
