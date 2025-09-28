# app/controllers/party/addresses_controller.rb
module Party
  class AddressesController < ApplicationController
    before_action :set_party
    before_action :set_address, only: %i[edit update destroy primary]
    before_action :load_ref_options, only: %i[new edit create update]

    def new
      @address = @party.addresses.new(country_code: "US", region_code: "MI")
      render layout: false
    end

    def edit
      render layout: false
    end

    def create
      @address = @party.addresses.new(address_params)
      if @address.save
        respond_to do |f|
          f.turbo_stream { render turbo_stream: refresh_list_and_close }
          f.html { redirect_to party_party_path(@party.public_id), notice: "Address added" }
        end
      else
        render :new, status: :unprocessable_entity, layout: false
      end
    end

    def update
      if @address.update(address_params)
        respond_to do |f|
          f.turbo_stream { render turbo_stream: refresh_list_and_close }
          f.html { redirect_to party_party_path(@party.public_id), notice: "Address updated" }
        end
      else
        render :edit, status: :unprocessable_entity, layout: false
      end
    end

    def destroy
      @address.destroy
      respond_to do |f|
        f.turbo_stream { render turbo_stream: [replace_list] }
        f.html { redirect_to party_party_path(@party.public_id), notice: "Address deleted" }
      end
    end

    def primary
      ::Party::Address.transaction do
        @party.addresses.update_all(is_primary: false)
        @address.update!(is_primary: true)
      end
      respond_to do |f|
        f.turbo_stream { render turbo_stream: [replace_list] }
        f.html { redirect_back fallback_location: party_party_path(@party.public_id) }
      end
    end

    private

    def set_party
      pid = params[:party_party_public_id] ||
            params[:party_party_id] ||
            params[:party_public_id] ||
            params[:public_id] ||
            params[:party_id]
      @party = ::Party::Party.find_by!(public_id: pid)
    end

    def set_address
      @address = @party.addresses.find(params[:id])
    end

    def address_params
      params.require(:party_address).permit(
        :address_type_code, :line1, :line2, :locality, :region_code, :postal_code, :country_code, :is_primary
      )
    end

    def replace_list
      @party.reload
      turbo_stream.replace(
        view_context.dom_id(@party, :addresses_section),
        partial: "party/addresses/list",
        locals: { party: @party }
      )
    end

    def refresh_list_and_close
      [replace_list, turbo_stream.replace("comm_modal_frame", partial: "shared/close_modal")]
    end

    def load_ref_options
      @address_types = Ref::AddressType.order(:name)
      @countries     = defined?(Ref::Country) ? Ref::Country.order(:name) : []
    end
  end
end
