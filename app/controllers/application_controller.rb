# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern

  helper_method :current_user, :authenticated?

  def current_user
    Current.user            # Authentication concern populates Current.session → Current.user
  end

  def authenticated?
    Current.user.present?
  end
end
