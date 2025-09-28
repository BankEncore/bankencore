# app/controllers/party/phones_controller.rb
module Party
  class PhonesController < ApplicationController
    before_action :set_party
    before_action :set_phone, only: %i[edit update destroy primary]
    before_action :load_ref_options, only: %i[new edit create update]

    def new
      @phone = @party.phones.new(country_alpha2: "US")
      render layout: false
    end

    def edit
      render layout: false
    end

    def create
      @phone = @party.phones.new(phone_params.merge(normalized_phone_attrs))
      if @phone.save
        respond_to do |f|
          f.turbo_stream { render turbo_stream: refresh_list_and_close }
          f.html { redirect_to party_party_path(@party.public_id), notice: "Phone added" }
        end
      else
        render :new, status: :unprocessable_entity, layout: false
      end
    end

    def update
      if @phone.update(phone_params.merge(normalized_phone_attrs))
        respond_to do |f|
          f.turbo_stream { render turbo_stream: refresh_list_and_close }
          f.html { redirect_to party_party_path(@party.public_id), notice: "Phone updated" }
        end
      else
        render :edit, status: :unprocessable_entity, layout: false
      end
    end

    def destroy
      @phone.destroy
      respond_to do |f|
        f.turbo_stream { render turbo_stream: [ replace_list ] }
        f.html { redirect_to party_party_path(@party.public_id), notice: "Phone deleted" }
      end
    end

    def primary
      ::Party::Phone.transaction do
        @party.phones.update_all(is_primary: false)
        @phone.update!(is_primary: true)
      end
      respond_to do |f|
        f.turbo_stream { render turbo_stream: [ replace_list ] }
        f.html { redirect_back fallback_location: party_party_path(@party.public_id) }
      end
    end

    private

    # ---------- Lookups / params ----------
    def set_party
      pid = params[:party_party_public_id] ||
            params[:party_party_id] ||
            params[:party_public_id] ||
            params[:public_id] ||
            params[:party_id]
      @party = ::Party::Party.find_by!(public_id: pid)
    end

    def set_phone
      @phone = @party.phones.find(params[:id])
    end

    def phone_params
      params.require(:party_phone).permit(
        :phone_type_code, :country_alpha2, :number_raw, :phone_ext, :consent_sms, :is_primary
      )
    end

    def load_ref_options
      @phone_types = Ref::PhoneType.order(:name)
      @countries   = Ref::Country.order(:name) if defined?(Ref::Country)
    end

    # ---------- Normalization ----------
    # Produces {:phone_e164 => "+15555551234", :number_raw => "555-555-1234", :country_alpha2 => "US"}
    def normalized_phone_attrs
      raw        = phone_params[:number_raw].to_s
      alpha2     = (phone_params[:country_alpha2].presence || @phone&.country_alpha2 || "US").upcase
      ext        = phone_params[:phone_ext].to_s.presence
      norm = normalize_to_e164(raw, alpha2)

      {
        phone_e164: norm,
        number_raw: raw,
        country_alpha2: alpha2,
        phone_ext: ext
      }
    end

    def normalize_to_e164(raw, alpha2)
      digits = raw.gsub(/[^\d+]/, "") # keep leading + if present
      # Try Phonelib first if present
      if defined?(Phonelib)
        Phonelib.default_country = alpha2
        parsed = Phonelib.parse(digits, alpha2)
        return parsed.e164 if parsed&.valid?
      end
      # Fallback simple normalizer
      cc = calling_code_for(alpha2) # e.g., "1" for US/CA, "33" for FR
      if digits.start_with?("+")
        "+#{digits.delete_prefix('+')}"
      else
        # If number starts with the national trunk '0' and country uses it (e.g., FR), drop it.
        stripped = digits.sub(/^0+/, "")
        "+#{cc}#{stripped}"
      end
    end

    # Use your ref table if available, else minimal map.
    def calling_code_for(alpha2)
      if defined?(Ref::Country) && Ref::Country.column_names.include?("calling_code")
        Ref::Country.find_by(code: alpha2)&.calling_code.to_s.presence || default_cc(alpha2)
      else
        default_cc(alpha2)
      end
    end

    def default_cc(alpha2)
      {
        "US" => "1", "CA" => "1",
        "FR" => "33", "GB" => "44", "DE" => "49",
        "AU" => "61", "NZ" => "64", "IN" => "91"
      }[alpha2] || "1"
    end

    # ---------- Turbo helpers ----------
    def replace_list
      @party.reload
      turbo_stream.replace(
        view_context.dom_id(@party, :phones_section),
        partial: "party/phones/list",
        locals: { party: @party }
      )
    end

    def refresh_list_and_close
      [ replace_list, turbo_stream.replace("comm_modal_frame", partial: "shared/close_modal") ]
    end
  end
end
