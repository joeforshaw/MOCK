class Solution < ActiveRecord::Base
  belongs_to :run
  has_many :clusters
end
