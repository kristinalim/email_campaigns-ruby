module MailingLists
  module ActiveRecord
    module ForMailingList
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        # Observes subscription attribute for changes, and synchronizes with
        # the mailing list.
        # 
        # Example Usage:
        # 
        #     class User < ActiveRecord::Base
        #       for_mailing_list :subscribed, :regular,
        #           :subscriber => {:email => :email_method,
        #           :name => :name_method}
        #     end
        def for_mailing_list(attribute, list_label, options = {})
          include ActiveRecord::ForMailingList::InstanceMethods

          after_create do |record|
            record.send(:synchronize_with_mailing_list!, attribute, list_label, options) if record.send(attribute)

            true
          end

          after_update do |record|
            record.send(:synchronize_with_mailing_list!, attribute, list_label, options) if record.send("#{attribute}_changed?")

            true
          end

          before_destroy do |record|
            if record.send(attribute)
              record.send("#{attribute}=", false)
              record.send(:synchronize_with_mailing_list!, attribute, list_label, options)
            end

            true
          end
        end
      end

      module InstanceMethods
        # Updates mailing list status to value of the attribute passed.
        # 
        # Note that this does an update whether or not the value of the
        # attribute has changed.
        # 
        #     full_options = {:subscriber => {:email => :email_address}}
        #     object.synchronize_with_mailing_list!(:subscribed, :one,
        #         full_options)
        def synchronize_with_mailing_list!(attribute, list_label, options = {})
          if send(attribute)
            mailing_list_subscribe!(list_label, options)
          else
            mailing_list_unsubscribe!(list_label, options)
          end
        end

        # Subscribes user to specified mailing list considering full options.
        # 
        #     full_options = {:subscriber => {:email => :email_address}}
        #     object.mailing_list_subscribe!(:one, full_options)
        def mailing_list_subscribe!(list_label, full_options = {})
          list = MailingLists::List.new(:label => list_label)
          subscriber = mailing_list_subscriber(full_options)
          list.subscribe(subscriber)
        end

        # Unsubscribes user from specified mailing list considering full
        # options.
        # 
        #     full_options = {:subscriber => {:email => :email_address}}
        #     object.mailing_list_subscribe!(:one, full_options)
        def mailing_list_unsubscribe!(list_label, full_options = {})
          list = MailingLists::List.new(:label => list_label)
          subscriber = mailing_list_subscriber(full_options)
          list.unsubscribe(subscriber)
        end

        # Returns built subscriber object considering subscriber options.
        # 
        #     full_options = {:subscriber => {:email => :email_address}}
        #     object.mailing_list_subscriber(full_options)
        def mailing_list_subscriber(full_options)
          subscriber = MailingLists::Subscriber.new

          options = subscriber_options(full_options)
          options.each { |k, v| subscriber.send("#{k}=", send(v)) }

          subscriber
        end

        # Returns merged default options and extract subscriber options from
        # passed Hash object. Default options are:
        # 
        #     email  :email
        #     name   :name
        # 
        #     full_options = {:subscriber => {:email => :email_address}}
        #     object.subscriber_options(full_options)
        #     => {:email => :email_address, :name => :name}
        def subscriber_options(full_options)
          options = {:email => :email, :name => :name}
          options.merge!(full_options[:subscriber]) unless full_options[:subscriber].blank?

          options
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, MailingLists::ActiveRecord::ForMailingList