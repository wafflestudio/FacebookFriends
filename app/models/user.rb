class User
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

# field
  field :fb_id, type: String
  field :name, type: String # Taekmin Kim
  field :username, type: String # taekmin.kim
  field :link, type: String # http://facebook.com/taekmin.kim
  field :gender, type: String # true : male, false : female
  field :updated_time, type: DateTime
  field :thumbnail, type: String

  has_mongoid_attached_file :profile_picture

# validation
  validates :fb_id, :uniqueness => true
  validates :name, :presence => true

# relations
  has_and_belongs_to_many :friends, :class_name => "User"
  has_and_belongs_to_many :schedules, :class_name => "Schedule", :inverse_of => :participants
  has_many :managed_schedule, :class_name => "Schedule", :inverse_of => :admin

# and so on
  index :fb_id, :unique => true
end
