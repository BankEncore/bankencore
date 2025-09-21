module Party
  class LinksController < ApplicationController
    # Create or list links across parties
    def index
      links = Link.order(created_at: :desc)
      render json: links
    end

    def create
      source = Party::Party.find_by!(public_id: link_params[:source_public_id])
      target = Party::Party.find_by!(public_id: link_params[:target_public_id])

      link = Link.new(
        source_party_id: source.id,
        target_party_id: target.id,
        party_link_type_code: link_params[:party_link_type_code]
      )

      if link.save
        render json: link, status: :created
      else
        render json: { errors: link.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      link = Link.find(params[:id])
      link.destroy
      head :no_content
    end

    private

    def link_params
      params.require(:link).permit(:source_public_id, :target_public_id, :party_link_type_code)
    end
  end
end
