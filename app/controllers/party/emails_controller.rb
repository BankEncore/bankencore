module Party
  class EmailsController < ApplicationController
    before_action :set_party
    before_action :set_email, only: [:update, :destroy]

    def index
      render json: @party.emails.order(created_at: :desc)
    end

    def create
      email = @party.emails.new(email_params)
      if email.save
        render json: email, status: :created
      else
        render json: { errors: email.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @email.update(email_params)
        render json: @email
      else
        render json: { errors: @email.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @email.destroy
      head :no_content
    end

    private

    def set_party
      @party = Party::Party.find_by!(public_id: params[:party_public_id])
    end

    def set_email
      @email = @party.emails.find(params[:id])
    end

    def email_params
      params.require(:email).permit(:email_type_code, :email, :is_primary)
    end
  end
end
