class Admin::PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_permission

  def index
    @available_roles = current_user.roles_accessible
  end

  def set_role
    @user = User.this_tenant.find(params[:user_id])
    role = params[:role_name]
    if current_user.roles_accessible.include?(role.to_sym)
      if @user.has_role? role
        @user.remove_role role
      else
        @user.add_role role
      end
      flash[:notice] = "Role updated"
    else
      flash[:alert] = "Role not found (#{role})"
    end

    redirect_to permissions_path
  end

  def set_password
    @user = User.this_tenant.find(params[:user_id])
    new_password = params[:password]

    @user.password = new_password

    if @user.save
      @user.confirm
      flash[:notice] = "Updated Password for #{@user}"
    else
      flash[:alert] = "Invalid Password"
    end
    redirect_to permissions_path
  end

  private

  def authorize_permission
    authorize :admin_permission
  end
end
