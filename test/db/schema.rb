ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string  :login
    t.string  :name
    t.string  :email
    t.string  :subscribed
  end
end