require "active_record"

class User < ActiveRecord::Base
  validates_presence_of :sender_id
end