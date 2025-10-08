# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :require_user
  def time_zone
    tz = params.require(:time_zone)
    return render json: { error: "invalid" }, status: :unprocessable_entity unless ActiveSupport::TimeZone[tz]
    Current.user.update!(time_zone: tz)
    head :no_content
  end
end
