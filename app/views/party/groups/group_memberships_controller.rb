# app/controllers/party/group_memberships_controller.rb
module Party
  class GroupMembershipsController < ApplicationController
    before_action :set_party
    before_action :load_groups, only: %i[new create]

    def new
      @membership = ::Party::GroupMembership.new
      render layout: false if turbo_frame_request?
    end

    def create
      Party::LinkSuggestion
      unless gid && ::Party::Group.exists?(gid)
        flash.now[:alert] = "Select a valid group"
        return render(:new, status: :unprocessable_content, layout: false)
      end

      ::Party::GroupMembership.find_or_create_by!(party_id: @party.id, group_id: gid)

      if turbo_frame_request?
        render turbo_stream: [ replace_groups_section, close_modal ]
      else
        redirect_to party_party_path(@party.public_id), notice: "Added to group"
      end
    end

    private

    def set_party
      pid = params[:public_id] || params[:party_party_public_id] || params[:party_public_id] || params[:id]
      @party = ::Party::Party.find_by!(public_id: pid)
    end

    def load_groups
      # requires scope: scope :of_type, ->(code) { code.present? ? where(party_group_type_code: code) : all }
      @groups = ::Party::Group.of_type(params[:group_type]).order(:name)
    end

    def gm_params
      params.require(:group_membership).permit(:group_id)
    end

    def replace_groups_section
      @party.reload
      turbo_stream.replace(
        view_context.dom_id(@party, :groups_section),
        partial: "party/groups/section",
        locals: { party: @party }
      )
    end

    def close_modal
      turbo_stream.replace("comm_modal_frame", partial: "shared/close_modal")
    end
  end
end
