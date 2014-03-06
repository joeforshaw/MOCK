class Users::SessionsController < Devise::SessionsController

  def new
    @body_classes << "login-body"
    super
  end

  protected

  def after_sign_in_path_for(resource)
    datasets_path
  end

end