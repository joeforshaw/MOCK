class AgglomNode < ActiveRecord::Base
  belongs_to :datapoint
  belongs_to :evidence_accumulation_solution

  acts_as_nested_set({:options => :dependent})

end
