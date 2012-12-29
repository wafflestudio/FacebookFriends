# encoding: utf-8
class History
  include Mongoid::Document
  include Mongoid::Timestamps

# fields
  field :type, type: Integer, :default => 0

# relations
  belongs_to :from, :class_name => "User", :inverse_of => :from_history
  belongs_to :to, :class_name => "User", :inverse_of => :to_history

# validations
  validates :from, :presence => true
  validates :to, :presence => true

# method start

  def return_type
    list = ["친구 맺기", "비활성화", "친구 끊기"]
    return list[type]
  end

# method end
end
