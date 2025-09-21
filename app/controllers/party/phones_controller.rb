module Party
  class PhonesController < ApplicationController
    before_action :set_party
    before_action :set_phone, only: [:update, :destroy]

    def index
      render json: @party.phones.order(created_at: :desc)
    end

    def create
      phone = @party.phones.new(phone_params)
      if phone.save
        render json: phone, status: :created
      else
        render json: { errors: phone.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @phone.update(phone_params)
        render json: @phone
      else
        render json: { errors: @phone.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @phone.destroy
      head :no_content
    end

    private

    def set_party
      @party = Party::Party.find_by!(public_id: params[:party_public_id])
    end

    def set_phone
      @phone = @party.phones.find(params[:id])
    end

    def phone_params
      params.require(:phone).permit(:phone_type_code, :phone_e164, :phone_ext, :is_primary, :consent_sms)
    end
  end
end
