class UsersController < ApplicationController
  require 'json'

	def create
	  @user=User.new(user_params)
    resp = @user.save
	  if resp[0]
      @result = resp[1].body
	  	flash[:success] = t(:user_creation_success_flash, user: @user.first_name)
	    redirect_to home_unverified_email_path
	  else
      flash[:danger] = t(:user_creation_error_flash)
		  redirect_to home_signup_path, layout: "logged_off"
	  end
	end

	def index
    	@users_list = User.all
  	end

  def change_access
    case params[:action_type]
      when 'revoke_access'
    	  User.revoke_access (params[:id])
  	    flash[:success] = t(:user_access_revoked_flash)
  	    redirect_to users_path
  	  when 'grant_access'
  		  User.grant_access (params[:id])
  		  flash[:success] = t(:user_access_granted_flash)
  		  redirect_to users_path
  	  else
        logger.debug "Invalid user access option: " + params[:action_type].to_s
  	    flash[:danger] = t(:saving_error_flash)
  	    redirect_to users_path
  	  end
  	end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation, :account_type, :position, :ticket_name)
  end
end




