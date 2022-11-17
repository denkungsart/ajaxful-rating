$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require "minitest/autorun"

require "rails"
require "active_record"
require "action_view"
require "ajaxful_rating"

AXR_FIXTURES_PATH = File.join(File.dirname(__FILE__), "fixtures")

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Load test models
Dir["#{AXR_FIXTURES_PATH}/*.rb"].each do |file|
  load file unless file.end_with?("schema.rb")
end

ActiveRecord::Migration.verbose = false
load File.join(AXR_FIXTURES_PATH, "schema.rb")
