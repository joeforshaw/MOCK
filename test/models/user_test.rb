require 'test_helper'

class UserTest < ActiveSupport::TestCase


  test "user can be created" do
    assert User.new(
      :name  => "Joe Duplicate",
      :email => "joe-duplicate@test.com",
      :password => "password"
    ).save, "Unable to create User"
  end


  test "name is needed to create user" do
    assert !User.new(
      :email => "joe-duplicate@test.com",
      :password => "password"
    ).save, "Saved user without a name"
  end


  test "email is needed to create user" do
    assert !User.new(
      :name => "Joe Duplicate",
      :password => "password"
    ).save, "Saved user without an email"
  end


  test "password is needed to create user" do
    assert !User.new(
      :name => "Joe Duplicate",
      :email => "joe-duplicate@test.com"
    ).save, "Saved user without an password"
  end


  test "user can be created with non-unique name" do
    assert User.new(
      :name  => "Joe",
      :email => "joe-duplicate@test.com",
      :password => "password"
    ).save, "Unable to create user with non-unique name"
  end


  test "user email must be unique" do
    assert !User.new(
      :name  => "Joe Duplicate",
      :email => "joe@test.com"
    ).save, "Saved user with non-unique email"
  end


  test "minimum length of password" do
    assert !User.new(
      :name  => "Joe Duplicate",
      :email => "joe-duplicate@test.com",
      :password => "passwor"
    ).save, "Created user with password less than 8 characters"
  end


  test "accessible fields" do
    @joe = User.find_by_name("Joe")
    assert @joe.email == "joe@test.com", "Failed to get existing user's email"
    assert @joe.name == "Joe", "Failed to get existing user's name"
  end


  test "inaccessible fields" do
    @joe = User.find_by_name("Joe")
    assert !@joe.password, "Failed to get existing user's name"
  end


end
