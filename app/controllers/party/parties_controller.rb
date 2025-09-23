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
      @party.emails.build if @party.emails.empty?
    end

    def edit
      @party.build_person       unless @party.person
      @party.build_organization unless @party.organization
      @party.addresses.build(country_code: "US") if @party.addresses.empty?
      @party.emails.build if @party.emails.empty?
    end

    def create
      raw = party_params

      if params[:add_email].present?
        @party = ::Party::Party.new(scrub_email_params(scrub_address_params(raw)))
        @party.emails.build
        render :new, status: :unprocessable_content and return
      end

      if params[:add_address].present?
        @party = ::Party::Party.new(scrub_email_params(scrub_address_params(raw)))
        @party.addresses.build(country_code: "US")
        render :new, status: :unprocessable_content and return
      end

      attrs = scrub_email_params(scrub_address_params(raw)).dup
      attrs.delete(:tax_id) if attrs[:tax_id].blank?

      @party = ::Party::Party.new(attrs)
      if @party.save
        redirect_to party_party_path(@party.public_id), notice: "Party created"
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      raw = party_params

      if params[:add_email].present?
        @party.assign_attributes(scrub_email_params(scrub_address_params(raw)))
        @party.emails.build
        render :edit, status: :unprocessable_content and return
      end

      if params[:add_address].present?
        @party.assign_attributes(scrub_email_params(scrub_address_params(raw)))
        @party.addresses.build(country_code: "US")
        render :edit, status: :unprocessable_content and return
      end

      attrs = scrub_email_params(scrub_address_params(raw)).dup
      attrs.delete(:tax_id) if attrs[:tax_id].blank?

      if @party.update(attrs)
        redirect_to party_party_path(@party.public_id), notice: "Party updated"
      else
        render :edit, status: :unprocessable_content
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
          :id, :legal_name, :organization_type_code, :formation_date, :_destroy
        ],
        addresses_attributes: [
          :id, :address_type_code, :line1, :line2, :line3, :locality,
          :region_code, :postal_code, :country_code, :is_primary, :_destroy
        ],
        emails_attributes: [
          :id, :email, :email_type_code, :is_primary, :_destroy
        ]
      )
    end

    def load_ref_options
      @address_types = Ref::AddressType.order(:name)
      @countries     = Ref::Country.order(:name)
      @org_types     = Ref::OrganizationType.order(:name)
      @email_types   = Ref::EmailType.order(:name)
    end

    def handle_bad_params(_ex)
      @party ||= ::Party::Party.new
      flash.now[:alert] = "Invalid form submission."
      render(action_name == "create" ? :new : :edit, status: :unprocessable_content)
    end

    # --- scrubbers ----------------------------------------------------------

    # Drop blank NEW email rows; keep existing rows even if email field blank
    def scrub_email_params(attrs)
      attrs = attrs.is_a?(ActionController::Parameters) ? attrs.to_unsafe_h : attrs
      attrs = attrs.deep_dup

      ehash = attrs[:emails_attributes]
      return attrs unless ehash.is_a?(Hash)

      cleaned = ehash.values.map { |h| h.symbolize_keys }

      cleaned.each do |h|
        h.delete(:email) if h[:id].present? && h[:email].to_s.strip.blank?
      end

      cleaned.select! do |h|
        !(h[:id].blank? && h[:email].to_s.strip.blank?)
      end

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

      cleaned.select! do |h|
        h[:id].present? || content_keys.any? { |k| h[k].to_s.strip.present? }
      end

      attrs[:addresses_attributes] = cleaned.each_with_index.to_h { |h, i| [i.to_s, h] }
      attrs
    end
  end
end
