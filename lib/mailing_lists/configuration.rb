module MailingLists
  class Configuration
    ERROR_MESSAGES = {
        :default => 'Error loading the configuration file.',
        :file_not_read => 'Error reading the configuration file.',
        :unconfigured_environment => 'No configuration for environment.',
        :undefined_service => 'Third-party service not specified.',
        :invalid_service => 'Third-party service not supported.',
        :no_list => 'No mailing list set up.',
        :incomplete_list => 'Incomplete list configuration. Take a look at test/config/mailing_lists.yml for reference.',
        :invalid_format => 'Invalid configuration format. Take a look at test/config/mailing_lists.yml for reference.',
    }

    attr_accessor :options, :service
 
    # Load configuration for MailingLists plugin.
    # 
    #     configuration = Configuration.new(file_path, environment)
    def initialize(file_path, environment)
      begin
        self.options = YAML.load_file(file_path)
      rescue
        return raise_exception(:file_not_read)
      end

      return raise_exception(:invalid_format) unless self.options.is_a?(Hash)

      self.options = self.options[environment]
      return raise_exception(:unconfigured_environment) if self.options.blank?

      return raise_exception(:invalid_format) unless self.options.is_a?(Hash)
      self.options.symbolize_keys!

      return raise_exception(:undefined_service) unless self.options.has_key?(:service)
      self.service = self.options[:service]
      return raise_exception(:invalid_service) unless Services.valid?(self.service)

      return raise_exception(:no_list) unless self.options.has_key?(:lists)
      return raise_exception(:invalid_format) unless self.options[:lists].is_a?(Hash)
      self.options[:lists].symbolize_keys!
      self.options[:lists].each do |label, configuration|
        list_configuration = self.options[:lists][label]
        return raise_exception(:invalid_format) unless list_configuration.is_a?(Hash)
        list_configuration.symbolize_keys!
      end

      self.options[:default_options] = {} unless self.options.has_key?(:default_options)
      return raise_exception(:invalid_format) unless self.options[:default_options].is_a?(Hash)
      self.options[:default_options].symbolize_keys!
    end

    protected

    # Raises MailingLists::Errors::ConfigurationException.
    # 
    # If the argument passed is nil, the default error message is used. If
    # the argument is a symbol, the corresponding message in MailingLists::
    # Configuration::ERROR_MESSAGES is used. Otherwise, the argument itself
    # is used.
    # 
    #     configuration.send(:raise_exception)
    def raise_exception(message = nil)
      message = ERROR_MESSAGES[message] if message.is_a?(Symbol)
      message ||= ERROR_MESSAGES[:default]
      raise Errors::ConfigurationException, message
    end
  end
end