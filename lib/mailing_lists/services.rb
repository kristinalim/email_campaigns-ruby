module MailingLists
  module Services
    SUPPORTED_SERVICES = ['campaign_monitor']

    # Returns true if the argument is a valid service string, and false
    # otherwise.
    # 
    #     MailingLists::Services.valid?("campaign_monitor")
    def self.valid?(service)
      SUPPORTED_SERVICES.include?(service)
    end
  end

  class Base
    # Adds subscriber to the mailing list. Override this method in actual
    # service handlers.
    # 
    #     Base.subscribe(list, subscriber)
    def self.subscribe(list, subscriber)
    end

    # Removes subscriber from the mailing list. Override this method in
    # actual service handlers.
    # 
    #     Base.unsubscribe(list, subscriber)
    def self.unsubscribe(list, subscriber)
    end
  end
end

require 'mailing_lists/services/campaign_monitor'