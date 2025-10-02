# app/controllers/party/groups_controller.rb
module Party
  class GroupsController < ApplicationController
    before_action :set_group, only: [ :show, :edit, :update, :destroy ]

    def index
      @groups = ::Party::Group.includes(:group_type).order(created_at: :desc)
    end

    def show; end
    def new  ; @group = ::Party::Group.new; end
    def edit ; end

    def create
      @group = ::Party::Group.new(group_params)
      @group.save ? redirect_to(@group, notice: "Group created") :
                    render(:new, status: :unprocessable_entity)
    end

    def update
      @group.update(group_params) ? redirect_to(@group, notice: "Group updated") :
                                    render(:edit, status: :unprocessable_entity)
    end

    def destroy
      @group.destroy
      redirect_to party_groups_path, notice: "Group deleted"
    end

    private

    def set_group
      @group = ::Party::Group.find(params[:id])
    end

    def group_params
      params.require(:party_group).permit(:party_group_type_code, :name)
    end
  end
end
