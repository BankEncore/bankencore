# app/controllers/party/links_controller.rb
module Party
  class LinksController < ApplicationController
    before_action :set_source

    def create
      target = ::Party::Party.find_by!(public_id: link_params.delete(:target_public_id))
      link   = ::Party::Link.new(link_params.merge(source_party: @party, target_party: target))

      if link.save
        respond_ok("Link created")
      else
        respond_err(link.errors.full_messages.to_sentence)
      end
    end

    def destroy
      link = ::Party::Link.find(params[:id])
      link.destroy
      respond_ok("Link removed")
    end

    private

    def set_source
      @party = ::Party::Party.find_by!(public_id: params[:party_party_id] || params[:party_id] || params[:party_public_id])
    end

    # expected params:
    # { party_link_type_code:, target_public_id:, started_on:, ended_on:, notes: }
    def link_params
      params.require(:party_link).permit(:party_link_type_code, :target_public_id, :started_on, :ended_on, :notes)
    end

    def respond_ok(msg)
      respond_to do |f|
        f.turbo_stream { head :ok }
        f.html  { redirect_back fallback_location: party_party_path(@party), notice: msg }
        f.json  { render json: { ok: true }, status: :ok }
      end
    end

    def respond_err(msg)
      respond_to do |f|
        f.turbo_stream { render status: :unprocessable_entity, plain: msg }
        f.html  { redirect_back fallback_location: party_party_path(@party), alert: msg }
        f.json  { render json: { ok: false, error: msg }, status: :unprocessable_entity }
      end
    end
  end
end
