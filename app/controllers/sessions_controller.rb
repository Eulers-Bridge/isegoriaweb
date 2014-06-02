class SessionsController < ApplicationController
  
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception
  
  #Function to create and start a new session
  def create
    
    @user = User.new(username: params[:session][:username], password: params[:session][:password])

    @user.authenticate

     I18n.locale = @user.locale || I18n.default_locale

    if !@user.verified_email
    redirect_to home_unverified_email_path
    elsif true
    	#transfer any data to the new session
      reset_session
    	session[:username] = params[:session][:username]
    	session[:authenticated] = true
      session[:locale] = @user.locale
    	logger.debug session[:username] + " authenticated " + session[:authenticated].to_s
	    redirect_to users_path
    else
      flash.now[:error] = t(:invalid_login_flash).capitalize #User not authenticated
      redirect_to root_path
    end
  end

  def destroy
  	username = session[:username].to_s
    session.destroy
  	logger.debug username + " session destroyed"
  	redirect_to root_path
  end

end
