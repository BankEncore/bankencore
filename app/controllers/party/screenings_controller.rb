# app/controllers/party/screenings_controller.rb
module Party
  class ScreeningsController < ApplicationController
    before_action :set_party, only: [ :index, :new, :create ]
    before_action :set_screening, only: [ :show, :edit, :update ]

    def index
      @screenings = @party.screenings.order(created_at: :desc)
    end

    def new
      @screening = @party.screenings.build(vendor: :manual, status: :pending)

      # prefill from party
      @screening.query_name    = @party.display_name
      @screening.query_dob     = @party.person&.date_of_birth
      @screening.query_country = @party.addresses.first&.country_code

      if (id = @party.identifiers.find(&:is_primary?))
        @screening.query_identifier_type  = id.id_type_code
        src = id.respond_to?(:masked_value) ? id.masked_value : (id.respond_to?(:value) ? id.value : "")
        @screening.query_identifier_last4 = src.to_s.gsub(/\D/, "")[-4, 4]
      end

      @screening.requested_at = Time.current
    end

    def create
      @screening = @party.screenings.build(screening_params.merge(vendor: :manual))
      @screening.completed_at ||= Time.current if @screening.status != "pending"
      @screening.expires_at ||= 24.hours.from_now if %w[sanctions pep watchlist adverse_media].include?(@screening.kind)

      if @screening.save
        redirect_to party_screening_path(@screening), notice: "Screening saved."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show; end
    def edit; end

    def update
      prev_status = @screening.status
      @screening.assign_attributes(screening_params)
      @screening.completed_at ||= Time.current if prev_status == "pending" && @screening.status != "pending"

      if @screening.save
        redirect_to party_screening_path(@screening), notice: "Updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_party
      # routes: namespace :party { resources :parties, param: :public_id do resources :screenings end }
      # params[:party_public_id] holds the UUID
      @party = ::Party::Party.find_by!(public_id: params[:party_public_id])
    end

    def set_screening
      @screening = ::Party::Screening.find(params[:id])
    end

    def screening_params
      p = params.require(:party_screening).permit(
        :kind, :status,
        :query_name, :query_dob, :query_country, :query_identifier_type, :query_identifier_last4,
        :vendor_ref, :vendor_score, :requested_at, :completed_at, :expires_at,
        :notes, :vendor_payload
      )
      # accept JSON string or hash
      if p[:vendor_payload].is_a?(String)
        p[:vendor_payload] = JSON.parse(p[:vendor_payload]) rescue {}
      end
      p
    end
  end
end
