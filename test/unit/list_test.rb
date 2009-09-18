require File.dirname(__FILE__) + '/../test_helper'

class ListTest < Test::Unit::TestCase
  context MailingLists::List do
    setup do
      configure
    end

    context "initialization" do
      should "be able to set list attributes" do
        initialize_list(:new)

        assert_equal list_attributes(:new)[:id], @list.id
        assert_equal list_attributes(:new)[:service], @list.service
        assert_equal list_attributes(:new)[:options], @list.options
      end

      context "with a label" do
        should "inherit configuration from MailingLists" do
          initialize_list(:one)

          assert_equal list_attributes(:one)[:id], @list.id
          assert_equal list_attributes(:one)[:service], @list.service
          assert_equal list_attributes(:one)[:options], @list.options
        end

        should "override attributes when specified" do
          options = {:label => :one}.merge(list_attributes(:new))
          @list = MailingLists::List.new(options)

          assert_equal list_attributes(:new)[:id], @list.id
          assert_equal list_attributes(:new)[:service], @list.service
          assert_equal list_attributes(:new)[:options], @list.options
        end
      end
    end

    context "subscribing" do
      setup do
        initialize_list(:one)
        initialize_subscriber(:one)
      end

      should "subscribe through service handler" do
        @list.send(:handler).expects(:subscribe).with(@list, @subscriber)
        @list.subscribe(@subscriber)
      end
    end

    context "unsubscribing" do
      setup do
        initialize_list(:one)
        initialize_subscriber(:one)
      end

      should "unsubscribe through service handler" do
        @list.send(:handler).expects(:unsubscribe).with(@list, @subscriber)
        @list.unsubscribe(@subscriber)
      end
    end

    context "retrieval of service handler" do
      setup do
        initialize_list(:one)
      end

      should "return service handler class when valid service" do
        @list.service = "campaign_monitor"
        assert_equal MailingLists::Services::CampaignMonitor,
            @list.send(:handler)
      end

      should "raise error when invalid service" do
        @list.service = "invalid"
        assert_raise MailingLists::Errors::ServiceException do
          @list.send(:handler)
        end
      end
    end
  end
end