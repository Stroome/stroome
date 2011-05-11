class PotentialUser < ActiveRecord::Base
  attr_accessor :message

  validates_presence_of :name, :email, :message
  validates_uniqueness_of :email
end
