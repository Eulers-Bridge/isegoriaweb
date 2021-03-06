class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  #helper_method will make any method available across the entire application
  helper_method :check_session
  helper_method :validate_authorized_access
  helper_method :general_error_redirection
  helper_method :current_user

  #before_actions will make a method run before actions are evaluated
  before_action :set_no_cache
  before_action :set_locale

  $title=''  #Initialize the title variable

  def current_user
    return session[:user]
  end

  #Function that sets the locale parameter that will determine which language and internacionalization features will be applied
  #Default locale is 'en' for English
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  #default_url_options is a Rails function that will allow us to modify the url
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }#We set the locale value into the url to read it and apply internacionalization between pages
  end

  #Function to disable cache properties to avoid ssession data to be cached
  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  #Function that will evaluate the session status of a user
  def check_session
		if session[:username].blank?
      flash[:danger] = t(:session_finished_flash).capitalize
			redirect_to root_path
      return false
		elsif session[:authenticated].blank?
      flash[:danger] = t(:session_finished_flash).capitalize
      #Destroy session from DB
			redirect_to root_path
      return false
		elsif !session[:authenticated]
      #Destroy session from DB
      flash[:danger] = t(:session_finished_flash).capitalize
      redirect_to root_path
      return false
	    elsif 
	    	logger.debug session[:username] + " session validated."
        return true
		end
	end

  #Function that will evaluate the session status of a user
  def logged_in?
    if session[:username].blank? or
       session[:authenticated].blank? or
       !session[:authenticated]
      return false
    end

    return true
  end

  #Function that evaluate and handle a 401 Unauthorized access and 403 Forbidden from the server
  def validate_authorized_access (response_code)
    if response_code == "401" or response_code == "403"
      #if the session is valid, then is real unauthorized access
      if check_session
        flash[:danger] = t(:unauthorized_access).capitalize
        redirect_to :back
        return false
      end
    else
      return true
    end
  end

  #Function to handle general errors
  def general_error_redirection(caller,error)
    flash[:danger] = t(:general_error) #Set the error message to the user
    Rails.logger.debug "*[ERROR] @ #{caller}=> #{error}." #Log the error
    Rails.logger.debug "#{error.backtrace}"
    redirect_to error_general_error_path #Redirect the user to the generic error page
  end

end
