# class Member < Sequel::Model
#   def validate
#     errors.add(:name, "can't be empty") if name.nil? || name.empty?
#   end
# end

class Member < ActiveRecord::Base
end