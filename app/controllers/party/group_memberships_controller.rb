module Party
  class GroupMembershipsController < ApplicationController
    before_action :set_group

    def index
      render json: @group.group_memberships.includes(:party)
    end

    def create
      party = Party::Party.find_by!(public_id: membership_params[:party_public_id])
      membership = @group.group_memberships.new(party_id: party.id)

      if membership.save
        render json: membership, status: :created
      else
        render json: { errors: membership.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      membership = @group.group_memberships.find(params[:id])
      membership.destroy
      head :no_content
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def membership_params
      params.require(:membership).permit(:party_public_id)
    end
  end
end
