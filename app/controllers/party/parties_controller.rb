# app/controllers/party/parties_controller.rb
module Party
  class PartiesController < ApplicationController
    before_action :set_party, only: [:show, :edit, :update, :destroy, :reveal_tax_id]
    before_action :load_ref_options, only: [:new, :edit, :create, :update]
    rescue_from ActionController::ParameterMissing, with: :handle_bad_params

    def index
      @parties = ::Party::Party.includes(:person, :organization).order(created_at: :desc)
    end

    def show; end

    def new
      @party = ::Party::Party.new(party_type: "person")
      @party.build_person
      @party.build_organization
      @party.addresses.build(country_code: "US")
    end

    def edit
      @party.build_person       unless @party.person
      @party.build_organization unless @party.organization
      @party.addresses.build if @party.addresses.empty?
    end

    def create
      attrs = party_params.dup
      attrs.delete(:tax_id) if attrs[:tax_id].blank?
      @party = ::Party::Party.new(attrs)

      if @party.save
        redirect_to party_party_path(@party.public_id), notice: "Party created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      attrs = party_params.dup
      attrs.delete(:tax_id) if attrs[:tax_id].blank?

      if @party.update(attrs)
        redirect_to party_party_path(@party.public_id), notice: "Party updated"
      else
        @party.build_person       unless @party.person
        @party.build_organization unless @party.organization
        @party.addresses.build if @party.addresses.empty?
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @party.destroy
      redirect_to party_parties_path, notice: "Party deleted"
    end

    # JSON: { value: "<decrypted tax_id>" }
    def reveal_tax_id
      # authorize @party if using Pundit
      render json: { value: @party.tax_id }
    end

    private

    def set_party
      @party = ::Party::Party.find_by!(public_id: params[:public_id])
    end

    def party_params
      params.require(:party).permit(
        :party_type, :tax_id,
        person_attributes: [:id, :first_name, :last_name, :date_of_birth, :_destroy],
        organization_attributes: [:id, :legal_name, :organization_type_code, :formation_date, :_destroy],
        addresses_attributes: [:id, :address_type_code, :line1, :line2, :line3, :locality,
                               :region_code, :postal_code, :country_code, :is_primary, :_destroy]
      )
    end

    def load_ref_options
      @address_types = RefAddressType.order(:name)
      @countries     = RefCountry.order(:name)
      @org_types     = RefOrganizationType.order(:name)
    end

    def handle_bad_params(_ex)
      @party ||= ::Party::Party.new
      flash.now[:alert] = "Invalid form submission."
      render(action_name == "create" ? :new : :edit, status: :unprocessable_entity)
    end
  end
end
