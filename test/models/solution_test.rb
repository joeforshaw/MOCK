require 'test_helper'

class SolutionTest < ActiveSupport::TestCase
   

  test "a solution can be created" do
    assert Solution.new(
      :run_id                => 1,
      :generated_solution_id => 1,
      :connectivity          => 1.0,
      :deviation             => 1.0,
      :parsed                => false
    ).save, "Can't create a solution"
  end


  test "creating a solution without a run_id" do
    assert !Solution.new(
      :generated_solution_id => 1,
      :connectivity          => 1.0,
      :deviation             => 1.0,
      :parsed                => false
    ).save, "Created a solution without a run_id"
  end


  test "creating a solution without a generated_solution_id" do
    assert !Solution.new(
      :run_id       => 1,
      :connectivity => 1.0,
      :deviation    => 1.0,
      :parsed       => false
    ).save, "Created a solution without a generated_solution_id"
  end


  test "creating a solution without a connectivity value" do
    assert !Solution.new(
      :run_id                => 1,
      :generated_solution_id => 1,
      :deviation             => 1.0,
      :parsed                => false
    ).save, "Created solution without a connectivity value"
  end


  test "creating control solution without a deviation value" do
    assert !Solution.new(
      :run_id                => 1,
      :generated_solution_id => 1,
      :connectivity          => 1.0,
      :parsed                => false
    ).save, "Created a solution without a deviation value"
  end


end
