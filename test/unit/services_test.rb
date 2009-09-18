require File.dirname(__FILE__) + '/../test_helper'

class ServicesTest < Test::Unit::TestCase
  context MailingLists::Services do
    setup do
      configure
      initialize_subscriber
    end

    context "validation of service strings" do
      should "return true if valid service" do
        assert_equal true,
            MailingLists::Services.valid?(valid_service_string)
      end

      should "return false if invalid service" do
        assert_equal false,
            MailingLists::Services.valid?(invalid_service_string)
      end
    end
  end
end