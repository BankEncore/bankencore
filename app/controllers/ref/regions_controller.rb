module Ref
  class RegionsController < ApplicationController
    def index
      code = params[:country].to_s.upcase
      regions = RefRegion.where(country_code: code).order(:name)
      render json: regions.select(:code, :name)
    end
  end
end
