# app/controllers/party/links_controller.rb
module Party
  class LinksController < ApplicationController
    before_action :set_source
    before_action :set_link_type, only: :create

    def create
      target = ::Party::Party.find_by!(public_id: pl_params[:target_public_id])

      from_allowed = json_list(@type.allowed_from_party_types)
      to_allowed   = json_list(@type.allowed_to_party_types)

      if from_allowed.any? && !from_allowed.include?(@party.party_type)
        return redirect_back fallback_location: party_party_path(@party.public_id),
                            alert: "Source must be #{from_allowed.join('/')}"
      end
      if to_allowed.any? && !to_allowed.include?(target.party_type)
        return redirect_back fallback_location: party_party_path(@party.public_id),
                            alert: "Target must be #{to_allowed.join('/')}"
      end

      ::Party::Link.create!(
        source_party: @party, target_party: target,
        party_link_type_code: @type.code,
        started_on: pl_params[:started_on], ended_on: pl_params[:ended_on]
      )
      if @type.inverse_code.present?
        ::Party::Link.create!(
          source_party: target, target_party: @party,
          party_link_type_code: @type.inverse_code,
          started_on: pl_params[:started_on], ended_on: pl_params[:ended_on]
        )
      end

      respond_to do |format|
        format.turbo_stream do
          links = ::Party::Link.involving(@party.id)
                  .includes(:party_link_type, :source_party, :target_party)
                  .order(:party_link_type_code)

          render turbo_stream: [
            turbo_stream.replace(
              "links_by_type",
              partial: "party/links/list_by_type",
              locals: { party: @party, links: links, editable: true }
            ),
            turbo_stream.replace(
              "comm_modal_frame",
              partial: "party/links/form",
              locals: { party: @party, link_types: Ref::PartyLinkType.order(:name) }
            )
          ]
        end
        format.html { redirect_to party_party_path(@party.public_id), notice: "Relationship added." }
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "comm_modal_frame",
            partial: "party/links/form",
            locals: { party: @party, link_types: Ref::PartyLinkType.order(:name) }
          ), status: :unprocessable_entity
        end
        format.html { redirect_back fallback_location: party_party_path(@party.public_id), alert: e.record.errors.full_messages.to_sentence }
      end
    end

    def destroy
      link = ::Party::Link.find(params[:id])
      authorize_source!(link)
      find_inverse(link)&.destroy!
      link.destroy!
      redirect_to party_party_path(@party.public_id), notice: "Relationship removed."
    end

    private

    def json_list(v)
      case v
      when Array  then v
      when String then (JSON.parse(v) rescue [ v ]).map(&:to_s)
      else Array(v).map(&:to_s)
      end
    end

    def set_source
      @party = ::Party::Party.find_by!(public_id: params[:party_public_id] || params[:party_id])
    end

    def set_link_type
      @type = Ref::PartyLinkType.find_by!(code: pl_params[:party_link_type_code])
    end

    def pl_params
      params.require(:party_link).permit(:party_link_type_code, :target_public_id, :started_on, :ended_on)
    end

    def authorize_source!(link)
      return if [ link.source_party_id, link.target_party_id ].include?(@party.id)
      raise ActiveRecord::RecordNotFound
    end

    def find_inverse(link)
      inv = Ref::PartyLinkType.find_by(code: link.party_link_type_code)&.inverse_code
      return nil if inv.blank?
      ::Party::Link.find_by(
        source_party_id: link.target_party_id,
        target_party_id: link.source_party_id,
        party_link_type_code: inv
      )
    end
  end
end
