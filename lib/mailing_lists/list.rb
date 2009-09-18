module MailingLists
  class List
    attr_accessor :label, :service, :id, :options

    # Initializes a list instance.
    # 
    # The following options can be used:
    # 
    #     :label    string   Loads list details from MailingLists options.
    #     :service  string   Specify the third-party service. Currently, only
    #                        "campaign_monitor" is supported.
    #     :id       string   List identifier at the third-party service.
    #     :options  hash     Other options necessary for accessing the
    #                        list through the API.
    # 
    #     list = List.new(:label => :one)
    def initialize(options = {})
      if options.has_key?(:label)
        self.label = options[:label].to_sym

        list_attributes = MailingLists.attributes_for_list(options[:label])
        self.id = list_attributes[:id]
        self.service = list_attributes[:service]
        self.options = list_attributes[:options]
      end

      self.service = options[:service] if options.has_key?(:service)
      self.id = options[:id] if options.has_key?(:id)
      self.options = options[:options] if options.has_key?(:options)
    end

    # Adds subscriber to the current mailing list. This calls the :subscribe
    # method implemented in the service handlers.
    # 
    #     list.subscribe(subscriber)
    def subscribe(subscriber)
      handler.subscribe(self, subscriber)
    end

    # Removes subscriber from the current mailing list. This calls the
    # :subscribe method implemented in the service handlers.
    # 
    #     list.unsubscribe(subscriber)
    def unsubscribe(subscriber)
      handler.unsubscribe(self, subscriber)
    end

    protected

    # Returns service handler for the current list. A NameError is raised if
    # the service handler does not exist (ie. the service is not supported).
    # 
    #     list.handler
    def handler
      "MailingLists::Services::#{service.to_s.camelcase}".constantize
    rescue
      raise Errors::ServiceException,
          'The mailing list service is not supported.'
    end
  end
end