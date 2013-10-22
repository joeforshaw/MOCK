class Users::SessionsController < Devise::SessionsController

  def new
    @body_classes << "login-body"
    super
  end

end