# app/controllers/party/groups/memberships_controller.rb
module Party
  module Groups
    class MembershipsController < ApplicationController
      before_action :set_group

      # POST /party/groups/:group_id/membership
      # Params can be either:
      #   { party_group_membership: { party_public_id: "..." } }
      # or { party_public_id: "..." }
      def create
        pid   = params.dig(:party_group_membership, :party_public_id) || params[:party_public_id]
        party = ::Party::Party.find_by!(public_id: pid)

        ::Party::GroupMembership.find_or_create_by!(group_id: @group.id, party_id: party.id)

        respond_to do |f|
          f.turbo_stream { head :ok }
          f.html { redirect_back fallback_location: party_group_path(@group), notice: "Member added" }
        end
      end

      # DELETE /party/groups/:group_id/membership?party_id=<public_id>
      def destroy
        if (pid = params[:party_id] || params[:party_public_id]).present?
          party = ::Party::Party.find_by!(public_id: pid)
          @group.group_memberships.where(party_id: party.id).destroy_all
        end

        respond_to do |f|
          f.turbo_stream { head :ok }
          f.html { redirect_back fallback_location: party_group_path(@group), notice: "Member removed" }
        end
      end

      private

      def set_group
        @group = ::Party::Group.find(params[:group_id])
      end
    end
  end
end
