# app/controllers/party/emails_controller.rb
module Party
  class EmailsController < ApplicationController
    before_action :set_party
    before_action :set_email, only: [:update, :destroy, :reveal]

    def index
      @emails = @party.emails.order(is_primary: :desc, created_at: :asc)
    end

    def create
      email = @party.emails.build(email_params)
      if email.save
        redirect_to party_party_path(@party.public_id), notice: "Email added"
      else
        redirect_to party_party_path(@party.public_id), alert: email.errors.full_messages.to_sentence
      end
    end

    def update
      if @email.update(email_params)
        redirect_to party_party_path(@party.public_id), notice: "Email updated"
      else
        redirect_to party_party_path(@party.public_id), alert: @email.errors.full_messages.to_sentence
      end
    end

    def destroy
      @email.destroy
      redirect_to party_party_path(@party.public_id), notice: "Email deleted"
    end

    def reveal
      render json: { value: @email.email }
    end

    private

    def set_party
      @party = ::Party::Party.find_by!(public_id: params[:party_public_id])
    end

    def set_email
      @email = @party.emails.find(params[:id])
    end

    def email_params
      params.require(:email).permit(:email, :email_type_code, :is_primary, :_destroy)
    end
  end
end
