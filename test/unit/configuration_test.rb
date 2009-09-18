require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationTest < Test::Unit::TestCase
  context MailingLists::Configuration do
    context "initialization" do
      should "correctly set options" do
        configure
        assert_equal configuration, @configuration.options
      end

      context "when file not accessible" do
        should "raise error" do
          assert_raise MailingLists::Errors::ConfigurationException,
              MailingLists::Configuration::ERROR_MESSAGES[:file_not_read] do
            @configuration = MailingLists::Configuration.
                new('inexistent.yml', 'test')
          end
        end
      end

      context "very specific validation when file loaded" do
        setup do
          configure
        end

        should "ensure entire configuration is a Hash" do
          raises_exception_loading(:invalid_format, [])
        end

        should "ensure configuration for environment" do
          raises_exception_loading(:unconfigured_environment, {})
        end

        should "ensure environment configuration is a Hash" do
          raises_exception_loading(:invalid_format, {'test' => [:foo, :bar]})
        end

        should "ensure service is defined" do
          raises_exception_loading(:undefined_service, {'test' =>
              {:foo => :bar}})
        end

        should "ensure service is valid" do
          raises_exception_loading(:invalid_service, {'test' =>
              {:service => 'invalid'}})
        end

        should "ensure lists is defined" do
          raises_exception_loading(:no_list, {'test' =>
              {:service => 'campaign_monitor'}})
        end

        should "ensure lists is a Hash" do
          raises_exception_loading(:invalid_format, {'test' =>
              {:service => 'campaign_monitor', :lists => []}})
        end

        should "ensure list hashes are Hash instances" do
          raises_exception_loading(:invalid_format, {'test' =>
              {:service => 'campaign_monitor', :lists => {:foo => :bar}}})
        end

        should "ensure default_options is a Hash" do
          raises_exception_loading(:invalid_format, {'test' =>
              {:service => 'campaign_monitor', :lists => {:foo => {
              :bar => :baz}, :default_options => :foo}}})
        end
      end

      should "initialize default_options but only when blank" do
        config = {'test' => {:service => 'campaign_monitor',
            :lists => {:foo => {:bar => :baz}}}}
        YAML.expects(:load_file).times(1).returns(config)
        configure
        assert_equal({}, @configuration.options[:default_options])
      end
    end

    context "raising of exceptions" do
      setup do
        configure
      end

      should "raise ConfigurationException and message with string" do
        message = "This is a message."
        assert_raise MailingLists::Errors::ConfigurationException, message do
          @configuration.send(:raise_exception, message)
        end
      end

      should "raise ConfigurationException and message with nil" do
        message = MailingLists::Configuration::ERROR_MESSAGES[:default]
        assert_raise MailingLists::Errors::ConfigurationException, nil do
          @configuration.send(:raise_exception, message)
        end
      end

      should "raise ConfigurationException and message with symbol" do
        message = MailingLists::Configuration::ERROR_MESSAGES[:file_not_read]
        assert_raise MailingLists::Errors::ConfigurationException,
            :file_not_read do
          @configuration.send(:raise_exception, message)
        end
      end
    end
  end

  def raises_exception_loading(error_key, config)
    @configuration.expects(:raise_exception).with(error_key).times(1)
    YAML.expects(:load_file).times(1).returns(config)

    @configuration.send :initialize, configuration_file_path, 'test'
  end
end