# app/controllers/party/parties_controller.rb
module Party
  class PartiesController < ApplicationController
    before_action :set_party, only: [:show, :edit, :update, :destroy, :reveal_tax_id]
    before_action :load_ref_options, only: [:new, :edit, :create, :update]
    rescue_from ActionController::ParameterMissing, with: :handle_bad_params

    def index
      @parties = ::Party::Party.includes(:person, :organization, :emails).order(created_at: :desc)
    end

    def show; end

    def new
      @party = ::Party::Party.new(party_type: "person")
      @party.build_person
      @party.build_organization
      @party.addresses.build(country_code: "US") if @party.addresses.empty?
      @party.emails.build                         if @party.emails.empty?
      @party.phones.build(country_alpha2: "US")   if @party.phones.empty?
    end

    def edit
      @party.build_person       unless @party.person
      @party.build_organization unless @party.organization
      @party.addresses.build(country_code: "US") if @party.addresses.empty?
      @party.emails.build                         if @party.emails.empty?
      @party.phones.build(country_alpha2: "US")   if @party.phones.empty?
    end

    def create
      return add_row_and_render(:new)  if params[:add_address] || params[:add_email] || params[:add_phone]

      attrs = scrub_email_params(scrub_address_params(party_params)).dup
      attrs.delete(:tax_id) if attrs[:tax_id].blank?

      @party = ::Party::Party.new(attrs)
      if @party.save
        redirect_to party_party_path(@party.public_id), notice: "Party created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      return add_row_and_render(:edit) if params[:add_address] || params[:add_email] || params[:add_phone]

      raw   = party_params
      attrs = scrub_email_params(scrub_address_params(raw)).dup
      attrs.delete(:tax_id) if attrs[:tax_id].blank?

      if @party.update(attrs)
        redirect_to party_party_path(@party.public_id), notice: "Party updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @party.destroy
      redirect_to party_parties_path, notice: "Party deleted"
    end

    def reveal_tax_id
      render json: { value: @party.tax_id }
    end

    private

    def set_party
      @party = ::Party::Party.find_by!(public_id: params[:public_id])
    end

    def party_params
      params.require(:party_party).permit(
        :party_type, :customer_number, :tax_id,
        person_attributes: [
          :id, :first_name, :middle_name, :last_name,
          :name_suffix, :courtesy_title, :date_of_birth, :_destroy
        ],
        organization_attributes: [
          :id, :legal_name, :operating_name, :organization_type_code, :formation_date, :_destroy
        ],
        addresses_attributes: [
          :id, :address_type_code, :line1, :line2, :line3, :locality,
          :region_code, :postal_code, :country_code, :is_primary, :_destroy
        ],
        emails_attributes: [
          :id, :email, :email_type_code, :is_primary, :_destroy
        ],
        phones_attributes: [
          :id, :phone_type_code, :number_raw, :country_alpha2, :phone_ext,
          :is_primary, :consent_sms, :_destroy
        ]
      )
    end

    def load_ref_options
      @address_types = Ref::AddressType.order(:name)
      @countries     = Ref::Country.order(:name)
      @org_types     = Ref::OrganizationType.order(:name)
      @email_types   = Ref::EmailType.order(:name)
      @phone_types   = Ref::PhoneType.order(:name)
    end

    def handle_bad_params(_ex)
      @party ||= ::Party::Party.new
      flash.now[:alert] = "Invalid form submission."
      render(action_name == "create" ? :new : :edit, status: :unprocessable_entity)
    end

    # ------- helpers --------------------------------------------------------

    def add_row_and_render(view)
      @party ||= ::Party::Party.new
      @party.assign_attributes(scrub_email_params(scrub_address_params(party_params)))
      @party.addresses.build(country_code: "US") if params[:add_address]
      @party.emails.build                        if params[:add_email]
      @party.phones.build(country_alpha2: "US")  if params[:add_phone]
      render view, status: :unprocessable_entity and return
    end

    # Drop blank NEW email rows; keep existing rows
    def scrub_email_params(attrs)
      attrs = attrs.is_a?(ActionController::Parameters) ? attrs.to_unsafe_h : attrs
      attrs = attrs.deep_dup
      ehash = attrs[:emails_attributes]
      return attrs unless ehash.is_a?(Hash)

      cleaned = ehash.values.map { |h| h.symbolize_keys }
      cleaned.each { |h| h.delete(:email) if h[:id].present? && h[:email].to_s.strip.blank? }
      cleaned.select! { |h| h[:id].present? || h[:email].to_s.strip.present? }
      attrs[:emails_attributes] = cleaned.each_with_index.to_h { |h, i| [i.to_s, h] }
      attrs
    end

    # Drop blank NEW address rows; keep existing rows
    def scrub_address_params(attrs)
      attrs = attrs.is_a?(ActionController::Parameters) ? attrs.to_unsafe_h : attrs
      attrs = attrs.deep_dup
      ahash = attrs[:addresses_attributes]
      return attrs unless ahash.is_a?(Hash)

      cleaned = ahash.values.map { |h| h.symbolize_keys }
      content_keys = %i[line1 line2 line3 locality region_code postal_code country_code address_type_code is_primary]
      cleaned.select! { |h| h[:id].present? || content_keys.any? { |k| h[k].to_s.strip.present? } }
      attrs[:addresses_attributes] = cleaned.each_with_index.to_h { |h, i| [i.to_s, h] }
      attrs
    end
  end
end
