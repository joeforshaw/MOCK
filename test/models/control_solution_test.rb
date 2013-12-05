require 'test_helper'

class ControlSolutionTest < ActiveSupport::TestCase
  

  test "control solution can be created" do
    assert ControlSolution.new(
      :run_id       => 1,
      :connectivity => 1.0,
      :deviation    => 1.0
    ).save, "Can't create a control solution"
  end


  test "creating a control solution with no run_id" do
    assert !ControlSolution.new(
      :connectivity => 1.0,
      :deviation    => 1.0
    ).save, "Created a control solution without a run_id"
  end


  test "creating a control solution with no connectivity" do
    assert !ControlSolution.new(
      :run_id       => 1,
      :deviation    => 1.0
    ).save, "Created a control solution without a connectivity value"
  end


  test "creating a control solution with no deviation" do
    assert !ControlSolution.new(
      :run_id       => 1,
      :connectivity => 1.0
    ).save, "Created a control solution without a deviation value"
  end


end
