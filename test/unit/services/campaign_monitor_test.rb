require File.dirname(__FILE__) + '/../../test_helper'

class CampaignMonitorTest < Test::Unit::TestCase
  context MailingLists::Services do
    setup do
      configure
      initialize_subscriber(:one)
      initialize_list(:one)
    end

    context "subscribing" do
      should "add subscriber to real mailing list" do
        # TODO
      end

      should "raise error when unsuccessful" do
        # TODO
      end
    end

    context "unsubscribing" do
      should "remove subscriber from real mailing list" do
        # TODO
      end

      should "raise error when unsuccessful" do
        # TODO
      end
    end
  end
end