# Define a module for observable behavior
module Observable
  def add_observer(observer)
    @observers ||= []
    @observers << observer
  end
 
  def remove_observer(observer)
    @observers.delete(observer) if @observers
  end
 
  def notify_observers(*args)
    @observers.each { |observer| observer.update(self, *args) } if @observers
  end
end
 
# Define a class representing a subject that can be observed
class DataStore
  include Observable
 
  attr_reader :data
 
  def initialize(initial_data = {})
    @data = initial_data
  end
 
  def update_data(key, value)
    old_value = @data[key]
    @data[key] = value
    notify_observers(key, old_value, value) # Notify observers of the change
  end
 
  # Metaprogramming example: dynamically define a method
  def self.define_accessor(name)
    define_method(name) do
      @data[name]
    end
 
    define_method("#{name}=") do |value|
      update_data(name, value)
    end
  end
end
 
# Define an observer class
class Logger
  def update(subject, key, old_value, new_value)
    puts "Logger: DataStore '#{subject.object_id}' updated. Key: #{key}, Old Value: #{old_value}, New Value: #{new_value}"
  end
end
 
# Define another observer class with a block-based update mechanism
class Analytics
  def initialize(&block)
    @analysis_block = block if block_given?
  end
 
  def update(subject, key, old_value, new_value)
    if @analysis_block
      @analysis_block.call(subject, key, old_value, new_value)
    else
      puts "Analytics: Received update for key '#{key}' in DataStore '#{subject.object_id}'."
    end
  end
end
 
# Usage example
data_store = DataStore.new(name: "My App", version: "1.0")
 
# Define dynamic accessors
DataStore.define_accessor(:name)
DataStore.define_accessor(:version)
 
logger = Logger.new
analytics_reporter = Analytics.new do |subject, key, old_value, new_value|
  puts "Analytics Reporter: Detailed analysis for DataStore '#{subject.object_id}': #{key} changed from '#{old_value}' to '#{new_value}'."
end
 
data_store.add_observer(logger)
data_store.add_observer(analytics_reporter)
 
puts "Initial Data: #{data_store.data}"
 
data_store.name = "My New App Name" # Triggers observers
data_store.version = "1.1" # Triggers observers
 
puts "Updated Data: #{data_store.data}"
 
# Remove an observer
data_store.remove_observer(logger)
 
data_store.name = "Final App Name" # Only analytics_reporter will be notified
