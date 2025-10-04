module Ref
  class RegionsController < ApplicationController
    skip_before_action :require_authentication, only: :index

    def index
      code = params[:country].to_s.upcase
      regions = Ref::Region.where(country_code: code).order(:name).select(:code, :name)
      expires_in 12.hours, public: true
      render json: regions
    end
  end
end