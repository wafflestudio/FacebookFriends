class User
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

  field :fb_id, type: String
  field :name, type: String # Taekmin Kim
  field :username, type: String # taekmin.kim
  field :link, type: String # http://facebook.com/taekmin.kim
  field :gender, type: String # true : male, false : female
  field :updated_time, type: DateTime

  has_mongoid_attached_file :profile_picture

  validates :fb_id, :uniqueness => true
  validates :name, :presence => true

  has_and_belongs_to_many :friends, :class_name => "User"

  index :fb_id, :unique => true
end
