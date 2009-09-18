require 'campaign_monitor'

module MailingLists
  module Services
    # Specify the service "campaign_monitor" in your configuration file if
    # you intend to use mailing lists on CampaignMonitor. The following
    # configuration options are required for each of your lists:
    # 
    #     api_key  string  API key for CampaignMonitor account.
    #     id       string  ID of list on CampaignMonitor.
    # 
    # Example configuration:
    # 
    #     production:
    #       service: campaign_monitor
    #       default_options:
    #         api_key: abcdefghij
    #       lists:
    #         one:
    #           id: 1
    # 
    # Further notes:
    # * This library assumes single opt-in mailing lists.
    class CampaignMonitor < Base
      def self.subscribe(list, subscriber)
        subscriber = ::CampaignMonitor::Subscriber.new(subscriber.email, subscriber.name)
        subscriber.instance_variable_get('@cm_client').
            instance_variable_set('@api_key', list.options[:api_key])
        subscriber.add_and_resubscribe(list.id)
      end

      def self.unsubscribe(list, subscriber)
        subscriber = ::CampaignMonitor::Subscriber.new(subscriber.email)
        subscriber.instance_variable_get('@cm_client').
            instance_variable_set('@api_key', list.options[:api_key])
        subscriber.unsubscribe(list.id)
      end
    end
  end
end

# API wrapper actually needs this to be set.
CAMPAIGN_MONITOR_API_KEY = nil