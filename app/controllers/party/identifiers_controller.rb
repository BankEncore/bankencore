# app/controllers/party/identifiers_controller.rb
class Party::IdentifiersController < ApplicationController
  before_action :set_party
  before_action :set_identifier

  def show
    render layout: false if turbo_frame_request?
    end

  def reveal
    render json: { value: @identifier.value } # decrypted by AR encrypts
  end

  private

  def set_party
    @party = ::Party::Party.find_by!(public_id: params[:party_public_id])
  end

  def set_identifier
    @identifier = @party.identifiers.find(params[:id])
  end
end
