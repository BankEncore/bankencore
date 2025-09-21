module Party
  class PeopleController < ApplicationController
    before_action :set_party
    before_action :ensure_party_type_person!

    def show
      render json: @party.person || {}
    end

    def create
      return render json: { error: "Person already exists" }, status: :conflict if @party.person
      person = @party.build_person(person_params)
      person.save! ? render(json: person, status: :created) :
                     render(json: { errors: person.errors.full_messages }, status: :unprocessable_entity)
    end

    def update
      person = @party.person or return render json: { error: "Not found" }, status: :not_found
      person.update(person_params) ? render(json: person) :
                                     render(json: { errors: person.errors.full_messages }, status: :unprocessable_entity)
    end

    def destroy
      @party.person&.destroy
      head :no_content
    end

    private

    def set_party
      @party = Party::Party.find_by!(public_id: params[:party_public_id])
    end

    def ensure_party_type_person!
      return if @party.party_type == "person"
      render json: { error: "party_type must be 'person' for this endpoint" }, status: :unprocessable_entity
    end

    def person_params
      params.require(:person).permit(:first_name, :last_name, :date_of_birth)
    end
  end
end
