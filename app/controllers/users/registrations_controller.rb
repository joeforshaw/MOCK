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
    Dataset.parse_csv("public/sample/sample-dataset.csv", user.id, "Sample dataset")
  end

end