class Run < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :user
  has_many :solutions
end
