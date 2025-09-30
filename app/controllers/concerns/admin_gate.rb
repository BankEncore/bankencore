# app/controllers/concerns/admin_gate.rb
module AdminGate
  extend ActiveSupport::Concern
  included { before_action :require_admin! }

  private
  def require_admin!
    unless authenticated?
      session[:return_to] = request.fullpath
      redirect_to(sign_in_path, alert: "Please sign in") and return
    end

    user_email = current_user.email_address.to_s.strip.downcase
    allowed    = ENV.fetch("ADMIN_EMAILS", "").split(",").map { _1.strip.downcase }.reject(&:blank?)

    Rails.logger.info("[AdminGate] user=#{user_email} allowed=#{allowed.inspect}")

    return if allowed.include?(user_email)
    head :forbidden
  end
end
