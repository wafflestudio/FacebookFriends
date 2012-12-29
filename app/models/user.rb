# encoding: utf-8
class User
  include Mongoid::Document
  include Mongoid::Timestamps

# field
  field :fb_id, type: String
  field :name, type: String # Taekmin Kim
  field :username, type: String # taekmin.kim
  field :link, type: String # http://facebook.com/taekmin.kim
  field :gender, type: String # true : male, false : female
  field :updated_time, type: DateTime
  field :last_login, type: DateTime
  field :thumbnail, type: String

# validation
  validates :fb_id, :uniqueness => true
  validates :name, :presence => true

# relations
  has_and_belongs_to_many :friends, :class_name => "User"
  has_and_belongs_to_many :schedules, :class_name => "Schedule", :inverse_of => :participants
  has_many :managed_schedule, :class_name => "Schedule", :inverse_of => :admin
  has_many :from_history, :class_name => "History", :inverse_of => :from
  has_many :to_history, :class_name => "History", :inverse_of => :to

# and so on
#  index :fb_id, :unique => true

# method start

  def self.set_history 
    puts "### Start History of Friends(User.set_history) ###"
    count = 0
    User.all.each do |u|
      u.friends.each do |friend|
        history = History.where(:from_id => u.id, :to_id => friend.id).last
        if history.nil? || history.type != 0
          history = History.create(:from_id => u.id, :to_id => friend.id, :type => 0)
          count += 1
        end
        history = History.where(:from_id => friend.id, :to_id => u.id).last
        if history.nil? || history.type != 0
          history = History.create(:from_id => friend.id, :to_id => u.id, :type => 0)
          count += 1
        end
      end
    end
    puts "#{count} == #{History.count}"
    puts "### End History of Friends(User.set_history) ###"
  end

# method end
end
