# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern

  helper_method :current_user, :authenticated?

  helper Rails.application.routes.url_helpers

  def current_user
    Current.user            # Authentication concern populates Current.session → Current.user
  end

  def authenticated?
    Current.user.present?
  end

  before_action :set_time_zone
  def set_time_zone
    Time.zone = Current.user&.time_zone.presence || "UTC"
  end
end
