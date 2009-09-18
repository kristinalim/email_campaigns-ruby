require File.dirname(__FILE__) + '/../test_helper'

class SubscriberTest < Test::Unit::TestCase
  context MailingLists::Subscriber do
    context "initialization" do
      setup do
        configure
        initialize_subscriber
      end

      should "correctly set attributes" do
        assert_not_nil @subscriber.id
        assert_not_nil @subscriber.email
        assert_not_nil @subscriber.display_name
        assert_not_nil @subscriber.first_name
        assert_not_nil @subscriber.last_name
      end
    end

    context "name" do
      setup do
        initialize_subscriber
      end

      should "be correct if first name is not set" do
        @subscriber.first_name = nil
        assert_nothing_raised { @subscriber.name }
        assert_equal @subscriber.name, "Bar"
      end

      should "be correct if last name is not set" do
        @subscriber.last_name = nil
        assert_nothing_raised { @subscriber.name }
        assert_equal @subscriber.name, "Foo"
      end

      should "be correct if first name and last name are not set" do
        @subscriber.first_name = nil
        @subscriber.last_name = nil
        assert_nothing_raised { @subscriber.name }
        assert_equal @subscriber.name, ""
      end

      should "be correct if first name and last name are set" do
        assert_nothing_raised { @subscriber.name }
        assert_equal @subscriber.name, "Foo Bar"
      end

      should "be specified name if set" do
        @subscriber.name = "foo-bar-baz"
        assert_equal @subscriber.name, "foo-bar-baz"
      end
    end
  end
end