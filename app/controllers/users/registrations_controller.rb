class Users::RegistrationsController < Devise::RegistrationsController

  def edit
    @body_classes << "user-register-body"
    super
  end

  def new
    @body_classes << "user-register-body"
    super
  end

  def create
    super
    user = User.find_by_email(params[:user][:email])
    Dataset.parse_csv("public/sample/sample-dataset.csv", user.id, "Car Efficiency Dataset")
  end

  protected

  def after_sign_up_path_for(resource)
    datasets_path
  end

end
