class Datavalue < ActiveRecord::Base
  belongs_to :datapoint, dependent: :destroy
end
