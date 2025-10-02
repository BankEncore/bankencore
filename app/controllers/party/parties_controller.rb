# app/controllers/party/parties_controller.rb
module Party
  class PartiesController < ApplicationController
    before_action :set_party, only: [ :show, :edit, :update, :destroy, :reveal_tax_id ]
    before_action :load_ref_options, only: [ :new, :edit, :create, :update ]
    rescue_from ActionController::ParameterMissing, with: :handle_bad_params
    helper ::Party::PartiesHelper

    # LIST + SEARCH
    def index
      qp    = params.permit(:q, :search_type, :sort, :dir, :page, :per)
      ppl   = ::Party::Person.table_name
      orgs  = ::Party::Organization.table_name
      emls  = ::Party::Email.table_name
      parts = ::Party::Party.table_name
      idts  = "party_identifiers"

      name_sql = "COALESCE(#{orgs}.legal_name, CONCAT_WS(' ', #{ppl}.first_name, #{ppl}.middle_name, #{ppl}.last_name))"
      sort     = qp[:sort].to_s
      dir      = %w[asc desc].include?(qp[:dir]) ? qp[:dir] : "asc"
      mode     = qp[:search_type].presence || "id_name"

      base = ::Party::Party
        .includes(:person, :organization, :emails, :phones, :addresses)
        .joins(<<~SQL.squish) # always join so ORDER BY works
          LEFT JOIN #{ppl}  ON #{ppl}.party_id  = #{parts}.id
          LEFT JOIN #{orgs} ON #{orgs}.party_id = #{parts}.id
          LEFT JOIN #{emls} ON #{emls}.party_id = #{parts}.id
        SQL
        .distinct

      scope =
        if mode == "tax_id" && qp[:q].present?
          bidx = tax_id_bidx_for(qp[:q])
          base.joins("INNER JOIN #{idts} ON #{idts}.party_id = #{parts}.id")
              .where("#{idts}.id_type_code IN ('ssn','itin','ein','foreign_tin') AND #{idts}.value_bidx = ?", bidx)
        else
          base.yield_self { |rel|
            if qp[:q].present?
              q = "%#{qp[:q].strip}%"
              rel.where(
                "#{ppl}.first_name LIKE :q OR #{ppl}.middle_name LIKE :q OR #{ppl}.last_name LIKE :q
                 OR #{orgs}.legal_name LIKE :q OR #{emls}.email LIKE :q OR #{parts}.customer_number LIKE :q",
                q: q
              )
            else
              rel
            end
          }
        end

      order_sql =
        case sort
        when "name"            then "#{name_sql} #{dir}"
        when "customer_number" then "#{parts}.customer_number #{dir}"
        when "updated_at"      then "#{parts}.updated_at #{dir}"
        else                         "#{parts}.updated_at DESC"
        end

      @parties = scope.reorder(Arel.sql(order_sql)).to_a
    end

    def show
      @party = ::Party::Party.find_by!(public_id: params[:public_id])
      @emails    = @party.emails.primary_first
      @phones    = @party.phones.primary_first
      @addresses = @party.addresses.primary_first
      @household = @party.groups.find_by(party_group_type_code: "household")
      @group     = @party.groups.find_by(party_group_type_code: "household")
    end

    def new
      @party = ::Party::Party.new(party_type: "person")
      @party.build_person
      @party.build_organization
      @party.addresses.build(country_code: "US") if @party.addresses.empty?
      @party.emails.build                         if @party.emails.empty?
      @party.phones.build(country_alpha2: "US")   if @party.phones.empty?
      ensure_identifier_stub(@party)
    end

    def edit
      @party.build_person       unless @party.person
      @party.build_organization unless @party.organization
      @party.addresses.build(country_code: "US") if @party.addresses.empty?
      @party.emails.build                         if @party.emails.empty?
      @party.phones.build(country_alpha2: "US")   if @party.phones.empty?
      ensure_identifier_stub(@party)
    end

    def create
      return add_row_and_render(:new)  if params[:add_address] || params[:add_email] || params[:add_phone] || params[:add_identifier]

      attrs = scrub_email_params(scrub_address_params(party_params)).dup
      @party = ::Party::Party.new(attrs)
      if @party.save
        redirect_to party_party_path(@party.public_id), notice: "Party created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      return add_row_and_render(:edit) if params[:add_address] || params[:add_email] || params[:add_phone] || params[:add_identifier]

      attrs = scrub_email_params(scrub_address_params(party_params)).dup
      if @party.update(attrs)
        redirect_to party_party_path(@party.public_id), notice: "Party updated"
      else
        load_ref_options
        ensure_identifier_stub(@party)
        render :edit, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique => e
      if mysql_dup_identifier?(e)
        # attach error to the edited identifier if present; else on base
        if (iid = params.dig(:party_party, :identifiers_attributes)&.values&.first&.dig(:id))
          rec = @party.identifiers.detect { |r| r.id.to_s == iid.to_s }
          rec&.errors&.add(:value, "is already in use by another profile")
        end
        @party.errors.add(:base, "That SSN/EIN is already in use by another profile")
        load_ref_options
        ensure_identifier_stub(@party)
        render :edit, status: :unprocessable_entity
      else
        raise
      end
    end

    def destroy
      @party.destroy
      redirect_to party_parties_path, notice: "Party deleted"
    end

    # JSON reveal for Tax ID (primary identifier value)
    def reveal_tax_id
      rec =
        if params[:identifier_id].present?
          @party.identifiers.find(params[:identifier_id])
        else
          @party.primary_tax_id
        end
      response.set_header("Cache-Control", "no-store")
      render json: { value: rec&.value }
    end

    def create_household
      party = ::Party::Party.find_by!(public_id: params[:public_id])
      name  = party.person ? "#{party.person.last_name} Household" : "#{party.display_name} Household"
      grp   = ::Party::Group.create!(party_group_type_code: "household", name: name)
      grp.group_memberships.create!(party_id: party.id)
      redirect_to party_group_path(grp), notice: "Household created"
    end

    private

    def set_party
      pid = params[:public_id] || params[:party_public_id] || params[:id]
      raise ActiveRecord::RecordNotFound, "missing public_id" if pid.blank?
      @party = ::Party::Party.find_by!(public_id: pid)
    end

    def party_params
      params.require(:party_party).permit(
        :party_type, # :customer_number intentionally omitted
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
          :phone_e164, :is_primary, :consent_sms, :_destroy
        ],
        identifiers_attributes: [
          :id, :identifier_type_id, :value, :is_primary,
          :country_code, :issuing_authority, :issued_on, :expires_on, :_destroy
        ]
      )
    end

    def load_ref_options
      @address_types = Ref::AddressType.order(:name)
      @countries     = Ref::Country.order(:name)
      @org_types     = Ref::OrganizationType.order(:name)
      @email_types   = Ref::EmailType.order(:name)
      @phone_types   = Ref::PhoneType.order(:name)
      @identifier_types = Ref::IdentifierType.order(:sort_order, :name)
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

      if params[:add_identifier]
        default_code = (@party.party_type == "organization" ? "ein" : "ssn")
        default_type = Ref::IdentifierType.find_by(code: default_code) || Ref::IdentifierType.first
        @party.identifiers.build(
          identifier_type: default_type,
          is_primary: @party.identifiers.tax_ids.where(is_primary: true).blank?
        )
      end

      render view, status: :unprocessable_entity
    end

    def scrub_email_params(attrs)
      attrs = attrs.is_a?(ActionController::Parameters) ? attrs.to_h : attrs
      attrs = attrs.deep_dup
      ehash = attrs[:emails_attributes]
      return attrs unless ehash.is_a?(Hash)

      cleaned = ehash.values.map { |h| h.symbolize_keys }
      cleaned.each { |h| h.delete(:email) if h[:id].present? && h[:email].to_s.strip.blank? }
      cleaned.select! { |h| h[:id].present? || h[:email].to_s.strip.present? }
      attrs[:emails_attributes] = cleaned.each_with_index.to_h { |h, i| [ i.to_s, h ] }
      attrs
    end

    def scrub_address_params(attrs)
      attrs = attrs.is_a?(ActionController::Parameters) ? attrs.to_h : attrs
      attrs = attrs.deep_dup
      ahash = attrs[:addresses_attributes]
      return attrs unless ahash.is_a?(Hash)

      cleaned = ahash.values.map { |h| h.symbolize_keys }
      content_keys = %i[line1 line2 line3 locality region_code postal_code country_code address_type_code is_primary]
      cleaned.select! { |h| h[:id].present? || content_keys.any? { |k| h[k].to_s.strip.present? } }
      attrs[:addresses_attributes] = cleaned.each_with_index.to_h { |h, i| [ i.to_s, h ] }
      attrs
    end

    def ensure_identifier_stub(party)
      return if party.identifiers.respond_to?(:tax_ids) && party.identifiers.tax_ids.exists?(is_primary: true)
      type = party.organization ? "ein" : "ssn"
      party.identifiers.build(id_type_code: type, is_primary: true)
    end

    # search helpers
    def normalize_tax_id(v)
      v.to_s.gsub(/\W/, "")
    end

    def tax_id_bidx_for(raw)
      norm = normalize_tax_id(raw)
      BlindIndex.generate_bidx(norm, key: BlindIndex.master_key, encode: false)
    end

    def list_params
      params.permit(:q, :search_type, :sort, :dir, :page, :per)
    end

    def identifier_bidx_for(raw, code)
      norm = ::Party::Identifier.normalize(raw, code)
      BlindIndex.generate_bidx(norm, key: BlindIndex.master_key, encode: false)
    end

    def mysql_dup_identifier?(err)
      cause = err.cause
      cause.respond_to?(:error_number) &&
        cause.error_number == 1062 &&                         # MySQL duplicate key
        err.message.include?("idx_unique_identifier_value")   # your unique index name
    end
  end
end
