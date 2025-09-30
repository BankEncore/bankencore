# app/controllers/admin/users_controller.rb
class Admin::UsersController < ApplicationController
  include AdminGate

  def index
    @users = User.order(:email_address, :first_name, :last_name)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "User created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy!
    redirect_to admin_users_path, notice: "User deleted."
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :email, :first_name, :last_name, :password, :password_confirmation)
      .delete_if { |_, v| v.blank? } # allow blank password on update
  end
end
