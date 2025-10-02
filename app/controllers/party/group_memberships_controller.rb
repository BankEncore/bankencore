# app/controllers/party/group_memberships_controller.rb
module Party
  class GroupMembershipsController < ApplicationController
    before_action :set_group

    def create
      party = ::Party::Party.find_by!(public_id: membership_params.delete(:party_public_id))
      m = @group.group_memberships.new(membership_params.merge(party_id: party.id))

      if m.save
        respond_ok("Member added")
      else
        respond_err(m.errors.full_messages.to_sentence)
      end
    end

    def update
      m = @group.group_memberships.find(params[:id])
      if m.update(membership_params.except(:party_public_id))
        respond_ok("Membership updated")
      else
        respond_err(m.errors.full_messages.to_sentence)
      end
    end

    def destroy
      @group.group_memberships.find(params[:id]).destroy
      respond_ok("Member removed")
    end

    private

    def set_group
      @group = ::Party::Group.find(params[:group_id])
    end

    # expected params:
    # { party_public_id:, role_code:, started_on:, ended_on: }
    def membership_params
      params.require(:party_group_membership).permit(:party_public_id, :role_code, :started_on, :ended_on)
    end

    def respond_ok(msg)
      respond_to do |f|
        f.turbo_stream { head :ok }
        f.html  { redirect_back fallback_location: party_group_path(@group), notice: msg }
        f.json  { render json: { ok: true }, status: :ok }
      end
    end

    def respond_err(msg)
      respond_to do |f|
        f.turbo_stream { render status: :unprocessable_entity, plain: msg }
      f.html  { redirect_back fallback_location: party_group_path(@group), alert: msg }
        f.json  { render json: { ok: false, error: msg }, status: :unprocessable_entity }
      end
    end
  end
end
