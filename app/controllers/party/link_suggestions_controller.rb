# app/controllers/party/link_suggestions_controller.rb
class Party::LinkSuggestionsController < ApplicationController
  before_action :authenticate_user!
  def index
    @suggestions = Party::LinkSuggestion.pending.order(confidence_score: :desc).limit(500).includes(:source_party, :target_party)
  end

  # PATCH /party/link_suggestions/:id
  # params: { decision: "accept"|"reject" }
  def update
    s = Party::LinkSuggestion.find(params[:id])
    case params[:decision]
    when "accept"
      Party::Link.create!(source_party_id: s.source_party_id, target_party_id: s.target_party_id, link_type_code: s.suggested_link_type_code)
      # inverse handled by existing callback
      s.update!(reviewed_flag: true, accepted_flag: true, reviewed_by: Current.user, reviewed_at: Time.current)
    when "reject"
      s.update!(reviewed_flag: true, accepted_flag: false, reviewed_by: Current.user, reviewed_at: Time.current)
    else
      head :unprocessable_entity and return
    end
    redirect_to party_link_suggestions_path, notice: "Updated"
  end
end
