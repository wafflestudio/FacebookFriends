class Schedule
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

# field
  field :started_at, type: DateTime
  field :ended_at, type: DateTime
  field :description, type: String

  has_mongoid_attached_file :picture,
    :styles => {:square50 => "50x50#"},
    :default_url => "/system/pictures/anonymous_:style.gif",
    :url => "/system/pictures/:id/:style",
    :path => Rails.root.to_s + "/public/system/pictures/:id/:style"

# relations
  belongs_to :admin, :class_name => "User", :inverse_of => :managed_schedule
  has_and_belongs_to_many :participants, :class_name => "User", :inverse_of => :schedules

# validations
  validates :started_at, :presence => true
  validates :ended_at, :presence => true
end
