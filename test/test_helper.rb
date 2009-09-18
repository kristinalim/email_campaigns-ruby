ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'activerecord'
require 'yaml'
require 'test/unit'
require 'shoulda'
require 'mocha'

require File.dirname(__FILE__) + '/../init'

# Load database configuration.
database_config = YAML.load_file(File.dirname(__FILE__) + '/config/database.yml')
ActiveRecord::Base.establish_connection(database_config['sqlite3'])

# Set up logger.
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log') 

# Load database schema.
require File.dirname(__FILE__) + '/db/schema'

# Set up ActiveRecord model for testing.
class User < ActiveRecord::Base
  for_mailing_list :subscribed, :one, :subscriber => {:name => :login}
end

class Test::Unit::TestCase
  protected

  def configure
    @configuration = MailingLists.configure(configuration_file_path)
  end

  def configuration
    {
        :service => 'campaign_monitor',
        :default_options => {
            :api_key => 'API_KEY',
            :client_id => 'CLIENT_ID',
            :campaign_id => 'CAMPAIGN_ID'
        },
        :lists => {
            :one => {
                :id => 'ONE'
            }
        }
    }
  end

  def configuration_file_path
    "#{File.dirname(__FILE__)}/config/mailing_lists.yml"
  end

  def initialize_subscriber(label = :default)
    @subscriber = MailingLists::Subscriber.new(subscriber_attributes(label))
  end

  def subscriber_attributes(label = :default)
    case label
    when :one:
      {
          :id => '1',
          :email => 'foo@bar.baz',
          :display_name => 'foo-bar',
          :first_name => 'Foo',
          :last_name => 'Bar'
      }
    else
      {
          :id => '1',
          :email => 'foo@bar.baz',
          :display_name => 'foo-bar',
          :first_name => 'Foo',
          :last_name => 'Bar'
      }
    end
  end

  def initialize_list(label = :default)
    @list = MailingLists::List.new(list_attributes(label))
  end

  def list_attributes(label = :default)
    case label
    when :new:
      {
          :id => "NEW_ID",
          :service => "NEW_SERVICE",
          :options => {
              :campaign_id => "NEW_CAMPAIGN_ID",
              :api_key => "NEW_API_KEY",
              :client_id => "NEW_CLIENT_ID"
          }
      }
    when :one:
      {
          :id => "ONE",
          :service => "campaign_monitor",
          :options => {
              :campaign_id => "CAMPAIGN_ID",
              :api_key => "API_KEY",
              :client_id => "CLIENT_ID"
          }
      }
    else
      nil
    end
  end

  def valid_service_string
    "campaign_monitor"
  end

  def invalid_service_string
    "invalid"
  end
end