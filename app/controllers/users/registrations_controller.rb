class Users::RegistrationsController < Devise::RegistrationsController

  def edit
    @body_classes << "user-register-body"
    super
  end

  def new
    @body_classes << "user-register-body"
    super
  end

end