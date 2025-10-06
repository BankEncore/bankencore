# app/controllers/party/group_suggestions_controller.rb
class Party::GroupSuggestionsController < ApplicationController
  before_action :authenticate_user!
  def index
    @suggestions = Party::GroupSuggestion.pending.order(confidence_score: :desc).limit(500)
  end

  # optional quick-create endpoint if you want to allow editing name before accept
  # POST /party/group_suggestions/:id/accept
  def update
    s = Party::GroupSuggestion.find(params[:id])
    case params[:decision]
    when "accept"
      group = Party::Group.create!(group_type_code: s.group_type_code, name: s.name)
      Array(s.members).each do |m|
        Party::GroupMembership.create!(
          group:, party_id: m["party_id"] || m[:party_id], role_code: m["role_code"] || m[:role_code]
        )
      end
      s.update!(reviewed_flag: true, accepted_flag: true, reviewed_by: Current.user, reviewed_at: Time.current)
    when "reject"
      s.update!(reviewed_flag: true, accepted_flag: false, reviewed_by: Current.user, reviewed_at: Time.current)
    else
      head :unprocessable_entity and return
    end
    redirect_to party_group_suggestions_path, notice: "Updated"
  end
end
