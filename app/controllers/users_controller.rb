class UsersController < ApplicationController
	require 'net/http'

	def create
	  puts "como pongo los datos que manda el post????"
	  pp(params)
	  @user=User.new(user_params)
	  if @user.save
	  	flash[:success] = t(:user_creation_success_flash)
	    redirect_to users_path
	  else
		render 'home/signup', layout: "logged_off"
	  end
	end

	def index
    	puts "Entro a la accion index del controlador user"
    	User.testReq
    	@users_list = User.all
  	end

  	def change_access
  	  case params[:action_type]
        when 'revoke_access'
  		  pp(params)
  		  User.revoke_access (params[:id])
  		  flash[:success] = t(:user_access_revoked_flash)
  		  redirect_to users_path
  		when 'grant_access'
  		  User.grant_access (params[:id])
  		  pp(params)
  		  flash[:success] = t(:user_access_granted_flash)
  		  redirect_to users_path
  	    else
          logger.debug "Invalid user access option: " + params[:action_type].to_s
  	    	flash[:error] = t(:saving_error_flash)
  	    	redirect_to users_path
  	  end
  	end

  	private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation, :account_type, :position, :ticket_name)
    end

end
