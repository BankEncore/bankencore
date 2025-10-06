# app/controllers/party/groups_controller.rb
module Party
  class GroupsController < ApplicationController
    before_action :set_group, only: [ :show, :edit, :update, :destroy ]

    def index
      @groups = ::Party::Group.includes(:group_type).order(created_at: :desc)
    end

    def show; end
    def new  ; @group = ::Party::Group.new; end
    def edit
      render layout: false
    end

    def create
      @group = ::Party::Group.new(group_params)
      @group.save ? redirect_to(@group, notice: "Group created") :
                    render(:new, status: :unprocessable_entity)
    end

    def update
      if @group.update(group_params)
        respond_to do |f|
          f.turbo_stream { redirect_to party_group_path(@group), notice: "Group renamed" }
          f.html { redirect_to party_group_path(@group), notice: "Group renamed" }
        end
      else
        render :edit, status: :unprocessable_content, layout: false
      end
    end

    def show
        @group = ::Party::Group.find(params[:id])
        @memberships = @group.group_memberships.includes(:party)
    end

    def destroy
      @group.destroy
      redirect_to party_groups_path, notice: "Group deleted"
    end

    private

    private
    def set_group   = @group = ::Party::Group.find(params[:id])
    def group_params = params.require(:party_group).permit(:name)
  end

    def lookup
        q = params[:q].to_s.strip
        rel = ::Party::Group.order(:name)
        rel = rel.where("name LIKE ?", "%#{q}%") if q.present?
        render json: rel.limit(20).pluck(:id, :name).map { |id, name| { id:, name: } }
    end
end
