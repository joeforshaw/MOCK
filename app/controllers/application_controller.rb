class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :create_body_classes

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  def create_body_classes
    @body_classes = []
  end

  def after_sign_in_path_for(resource)
    :root
  end

end
