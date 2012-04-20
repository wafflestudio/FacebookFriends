class User
  include Mongoid::Document
  include Mongoid::Paperclip


  field :fb_id, type: String
  field :name, type: String
  has_mongoid_attached_file :profile_picture

  validates :fb_id, :uniqueness => true
  validates :name, :presence => true

  has_and_belongs_to_many :friends, :class_name => "User"

  index :fb_id, :unique => true
end
