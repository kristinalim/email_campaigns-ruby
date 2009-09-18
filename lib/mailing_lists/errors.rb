module MailingLists
  module Errors
    class ServiceException < RuntimeError
    end

    class ConfigurationException < RuntimeError
    end
  end
end