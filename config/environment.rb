ENV['RAILS_ENV'] ||= 'production'
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Projectplay::Application.initialize!
