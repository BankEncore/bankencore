class HomeController < ApplicationController
  def index
    @recent_parties = ::Party::Party
      .includes(:person, :organization)
      .order(updated_at: :desc)
      .limit(10)
  end
end
