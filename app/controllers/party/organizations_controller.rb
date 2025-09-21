module Party
  class OrganizationsController < ApplicationController
    before_action :set_party
    before_action :ensure_party_type_org!

    def show
      render json: @party.organization || {}
    end

    def create
      return render json: { error: "Organization already exists" }, status: :conflict if @party.organization
      org = @party.build_organization(org_params)
      org.save! ? render(json: org, status: :created) :
                  render(json: { errors: org.errors.full_messages }, status: :unprocessable_entity)
    end

    def update
      org = @party.organization or return render json: { error: "Not found" }, status: :not_found
      org.update(org_params) ? render(json: org) :
                               render(json: { errors: org.errors.full_messages }, status: :unprocessable_entity)
    end

    def destroy
      @party.organization&.destroy
      head :no_content
    end

    private

    def set_party
      @party = Party::Party.find_by!(public_id: params[:party_public_id])
    end

    def ensure_party_type_org!
      return if @party.party_type == "organization"
      render json: { error: "party_type must be 'organization' for this endpoint" }, status: :unprocessable_entity
    end

    def org_params
      params.require(:organization).permit(:legal_name, :organization_type_code, :formation_date)
    end
  end
end
