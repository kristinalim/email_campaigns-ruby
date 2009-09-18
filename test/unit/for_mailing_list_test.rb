require File.dirname(__FILE__) + '/../test_helper'

class ForMailingListTest < Test::Unit::TestCase
  context MailingLists::ActiveRecord::ForMailingList do
    setup do
      configure
      set_default_options
      initialize_object
    end

    context "for_mailing_list filters" do
      context "when new object" do
        should "add subscriber if creating subscribed" do
          @options = {:subscriber => {:name => :login}}
          @object.expects(:synchronize_with_mailing_list!).never
          @object.save
        end

        should "not add subscriber if creating unsubscribed" do
          @options = {:subscriber => {:name => :login}}
          @object.subscribed = true
          @object.expects(:synchronize_with_mailing_list!).with(:subscribed, :one, @options).returns(true).at_least_once
          @object.save
        end
      end

      context "when an existing record already subscribed" do
        setup do
          @options = {:subscriber => {:name => :login}}
          @object.subscribed = true
          @object.expects(:synchronize_with_mailing_list!).with(:subscribed, :one, @options).returns(true).at_least_once
          @object.save
        end

        should "not synchronize if updating still subscribed" do
          @object.email = "new email"
          @object.expects(:synchronize_with_mailing_list!).never
          @object.save
        end

        should "synchronize if updating unsubscribed" do
          @object.email = "new email"
          @object.subscribed = false
          @object.expects(:synchronize_with_mailing_list!).with(:subscribed, :one, @options).returns(true).at_least_once
          @object.save
        end

        should "unsubscribe if deleted" do
          @object.expects(:synchronize_with_mailing_list!).with(:subscribed, :one, @options).at_least_once
          @object.destroy
        end
      end

      context "when an existing record not subscribed" do
        setup do
          @options = {:subscriber => {:name => :login}}
          @object.subscribed = false
          @object.expects(:synchronize_with_mailing_list!).with(:subscribed, :one, @options).returns(true).never
          @object.save
        end

        should "not synchronize if updating still not subscribed" do
          @object.email = "new email"
          @object.expects(:synchronize_with_mailing_list!).never
          @object.save
        end

        should "synchronize if updating subscribed" do
          @object.email = "new email"
          @object.subscribed = true
          @object.expects(:synchronize_with_mailing_list!).with(:subscribed, :one, @options).returns(true).at_least_once
          @object.save
        end

        should "not synchronize if deleted" do
          @object.expects(:synchronize_with_mailing_list!).never
          @object.destroy
        end
      end
    end

    context "synchronization with mailing list" do
      should "subscribe when true" do
        @options = {:foo => :bar}

        @object.expects(:subscribed).returns(true).at_least_once
        @object.expects(:mailing_list_subscribe!).with(:one, @options).at_least_once
        @object.send(:synchronize_with_mailing_list!, :subscribed, :one, @options)
      end

      should "unsubscribe when false" do
        @options = {:foo => :bar}

        @object.expects(:subscribed).returns(false).at_least_once
        @object.expects(:mailing_list_unsubscribe!).with(:one, @options).at_least_once
        @object.send(:synchronize_with_mailing_list!, :subscribed, :one, @options)
      end

      should "be able to subscribe" do
        @options = {:foo => :bar}
        @list = MailingLists::List.new(:label => :one)
        @subscriber = @object.send(:mailing_list_subscriber, @options)

        MailingLists::List.expects(:new).with(:label => :one).returns(@list)
        @object.expects(:mailing_list_subscriber).with(@options).
            returns(@subscriber)
        @list.expects(:subscribe).with(@subscriber)

        @object.send(:mailing_list_subscribe!, :one, @options)
      end

      should "be able to unsubscribe" do
        @options = {:foo => :bar}
        @list = MailingLists::List.new(:label => :one)
        @subscriber = @object.send(:mailing_list_subscriber, @options)

        MailingLists::List.expects(:new).with(:label => :one).returns(@list)
        @object.expects(:mailing_list_subscriber).with(@options).
            returns(@subscriber)
        @list.expects(:unsubscribe).with(@subscriber)

        @object.send(:mailing_list_unsubscribe!, :one, @options)
      end
    end

    context "building of subscriber object" do
      should "be able to set with default options" do
        @subscriber = @object.send(:mailing_list_subscriber, {})
        assert_equal @object.send(@default_options[:email]),
            @subscriber.email
        assert_equal @object.send(@default_options[:name]),
            @subscriber.name
      end

      should "be able to override default options" do
        @options = {:subscriber => {:name => :login}}
        
        @subscriber = @object.send(:mailing_list_subscriber, @options)
        assert_equal @object.send(@default_options[:email]),
            @subscriber.email
        assert_equal @object.send(@options[:subscriber][:name]),
            @subscriber.name
      end
    end

    context "extraction of subscriber options" do
      should "be default when no subscriber option is passed" do
        assert_equal @default_options, @object.send(:subscriber_options, {})
      end

      should "return merged result when subscriber options are passed" do
        options = {}
        assert_equal @default_options.merge(options),
            @object.send(:subscriber_options, {:subscriber => options})

        options = {:subscriber => {:email => :email_address}}
        assert_equal @default_options.merge(options),
            @object.send(:subscriber_options, {:subscriber => options})
      end
    end
  end

  def klass
    User
  end

  def initialize_object
    @object = User.new(
        :email => "foo@bar.baz",
        :login => "foo-bar",
        :name => "Foo Bar"
    )
  end

  def set_default_options
    @default_options = {:email => :email, :name => :name}
  end
end