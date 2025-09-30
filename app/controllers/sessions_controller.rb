# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]

  def new; end

  def create
    email = params[:email_address].to_s.downcase
    user  = User.find_by(email_address: email)

    if user&.authenticate(params[:password])
      # end any existing DB session for this browser
      Current.session&.destroy
      cookies.delete(:session_id)

      # start a new DB session and set the signed cookie
      s = Session.create!(user: user)
      cookies.signed[:session_id] = {
        value: s.id,
        httponly: true,
        same_site: :lax
      }

      redirect_to(session.delete(:return_to) || root_path)
    else
      flash.now[:alert] = "Invalid credentials"
      render :new, status: :unauthorized
    end
  end

  def destroy
    Current.session&.destroy
    cookies.delete(:session_id)
    redirect_to sign_in_path, notice: "Signed out"
  end
end
