module MailingLists
  class Subscriber
    attr_accessor :email, :id, :display_name, :first_name, :last_name

    # Initializes a subscriber instance.
    # 
    # The following options are recognized:
    # 
    #     :id            string  Subscriber identifier at the third-party
    #                            service.
    #     :email         string  Email address of the subscriber.
    #     :first_name    string  First name of the subscriber.
    #     :last_name     string  Last name of the subscriber.
    #     :display_name  string  Nick name for the subscriber.
    # 
    #     subscriber = Subscriber.new(:id => 'foo')
    def initialize(options = {})
      self.id = options[:id]
      self.email = options[:email]
      self.first_name = options[:first_name]
      self.last_name = options[:last_name]
      self.display_name = options[:display_name]
    end

    # Concatenates first name and last name.
    # 
    #     subscriber.name
    #     => "Foo, Bar"
    def name
      @name ||
          [self.first_name, self.last_name].reject { |n| n.blank? }.join(' ')
    end

    # Overrides value for :name method.
    # 
    #     subscriber.name = "foo-bar"
    #     subscriber.name
    #     => "foo-bar"
    def name=(value)
      @name = value
    end
  end
end