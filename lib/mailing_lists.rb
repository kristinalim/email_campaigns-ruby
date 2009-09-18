require 'mailing_lists/errors'
require 'mailing_lists/configuration'
require 'mailing_lists/list'
require 'mailing_lists/subscriber'
require 'mailing_lists/services'

require 'mailing_lists/active_record/for_mailing_list'

module MailingLists
  SERVICES = [:campaign_monitor]

  mattr_accessor :configuration

  def self.configure(file_path = nil)
    file_path = self.default_configuration_path if file_path.blank?
    self.configuration = Configuration.new(file_path, ENV['RAILS_ENV'])
  end

  def self.options
    self.configuration ||= Configuration.new(self.default_configuration_path, ENV['RAILS_ENV'])
    self.configuration.options
  end

  def self.attributes_for_list(label)
    list_options = self.options[:lists][label].dup
    list_options.reverse_merge!(self.options[:default_options])

    list_attributes = {}
    list_attributes[:id] = list_options.delete(:id)
    list_attributes[:service] = self.options[:service]
    list_attributes[:options] = list_options

    list_attributes
  end

  def self.default_configuration_path
    "#{RAILS_ROOT}/config/mailing_lists.yml"
  end
end