class SessionsController < ApplicationController
  
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception
  
  #Function to create and start a new session
  def create
    
    @user = User.new(email: params[:session][:username], password: params[:session][:password])

    resp = @user.authenticate

    if resp[0]
      @user = JSON.parse(resp[1])['user']
      @user['id']=JSON.parse(resp[1])['userId']
      I18n.locale = @user.has_key?("user") ? @user.locale : I18n.default_locale
      if !@user['accountVerified']
        redirect_to home_unverified_email_path
      else
        #transfer any data to the new session
        reset_session
        session[:user] = @user
        session[:username] = @user['email']
        session[:password] = @user['password']
        session[:authenticated] = true
        session[:locale] = I18n.locale
        logger.debug session[:username] + " Authenticated: " + session[:authenticated].to_s
        redirect_to articles_path
      end
    else
      logger.debug params[:session][:username] + " Not authenticated: " + resp[1] 
      flash[:danger] = t(:invalid_login_flash).capitalize
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
