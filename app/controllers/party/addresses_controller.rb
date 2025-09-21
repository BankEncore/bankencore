module Party
  class AddressesController < ApplicationController
    before_action :set_party
    before_action :set_address, only: [:update, :destroy]

    def index
      render json: @party.addresses.order(created_at: :desc)
    end

    def create
      addr = @party.addresses.new(address_params)
      if addr.save
        render json: addr, status: :created
      else
        render json: { errors: addr.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @address.update(address_params)
        render json: @address
      else
        render json: { errors: @address.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @address.destroy
      head :no_content
    end

    private

    def set_party
      @party = Party::Party.find_by!(public_id: params[:party_public_id])
    end

    def set_address
      @address = @party.addresses.find(params[:id])
    end

    def address_params
      params.require(:address).permit(
        :address_type_code, :line1, :line2, :line3, :locality,
        :region_code, :postal_code, :country_code, :is_primary
      )
    end
  end
end
