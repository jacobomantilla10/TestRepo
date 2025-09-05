module Loggable
  def log(message)
    puts "[#{Time.now}] #{message}"
  end
end

class Task
  include Loggable

  attr_reader :name, :duration

  def initialize(name, duration)
    @name = name
    @duration = duration
  end

  def execute
    log("Starting task: #{@name}")
    sleep(@duration)
    log("Finished task: #{@name}")
  end
end

class TimedTask < Task
  def execute
    start_time = Time.now
    super
    end_time = Time.now
    log("Task #{@name} took #{end_time - start_time} seconds.")
  end
end

class Scheduler
  def initialize
    @tasks = []
  end

  def add_task(task)
    @tasks << task
  end

  def run_all
    @tasks.each(&:execute)
  end
end

# Example usage
scheduler = Scheduler.new
scheduler.add_task(Task.new("Backup", 1))
scheduler.add_task(TimedTask.new("Cleanup", 2))
scheduler.run_all
