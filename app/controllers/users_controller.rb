class UsersController < ApplicationController

  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to sign up a new User, created without being logged in
--------------------------------------------------------------------------------------------------------------------------------
=end
  def signup
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @user = User.new(user_params) #Create a new User object with the parameters set by the user in the create form
    response = @user.save #Save the new User object
    if response[0] #Validate if the response was successfull
      flash[:success] = t(:user_creation_success_flash, user: @user.email) #Set the success message for the user
      redirect_to home_unverified_email_path #Redirect the user to the verify email
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(response[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid photo album object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(response[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:user_creation_error_flash) #Set the error message for the user
      redirect to register_successfull_path, layout: "logged_off"
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the users from the model
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    page_aux = params[:page] #Retrieve the params from the query string
    @page = page_aux =~ /\A\d+\z/ ? page_aux.to_i : 0 #Validate if the page_aux param is turnable to an integer, otherwise set it to cero
    response = User.all(session[:user],@page) #Retrieve all the users from the model
    if response[0] #Validate if the response was successfull
      @users_list = response[1] #Get the users list from the response
      total_pages = response[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:user_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new user page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @user = User.new #Set a new user object to be filled with the create form
    response = Country.general_info #Retrieve the countries and institutions catalog
    if response[0] #Validate if the response was successfull
      @countries_catalog = response[1] #Get the countries list from the response
      @countries_js_string = response[2]
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:country_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new User
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @user = User.new(user_params) #Create a new User object with the parameters set by the user in the create form
    response = @user.save #Save the new User object
    if response[0] #Validate if the response was successfull
      flash[:success] = t(:user_creation_success_flash, user: @user.email) #Set the success message for the user
      redirect_to users_path #Redirect the user to the user list page
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(response[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid photo album object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(response[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:user_creation_error_flash) #Set the error message for the user
      @user = User.new #Reset the User object to an empty one
      redirect_to new_user_path #Redirect the user to the User creation page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit user page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    response = User.find(params[:email],session[:user]) #Retrieve the user to update
    if response[0] #Validate if the response was successfull 
    @user = response[1] #Set the user object to fill the edit form
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:user_get_error_flash) #Set the error message for the user
      redirect_to user_path #Redirect the user to edit user page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update a User
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    response = User.find(params[:email],session[:user]) #Retrieve the original user object to update
    if response[0] #Validate if the response was successfull 
      @user = response[1] #Set the user object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:user_get_error_flash) #Set the error message for the user
      redirect_to users_path #Redirect the user to the users list page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    response2 = @user.update_attributes(user_params,session[:user]) #Update the user object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:user_modification_success_flash, user: @user.email) #Set the success message for the user
      redirect_to users_path #Redirect the user to the users list page
    elsif validate_authorized_access(response2[1])#If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(response2[1].kind_of?(Array))#If the response was unsucessful, validate if it was caused by an invalid User object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(response2[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:user_modification_error_flash) #Set the error message for the user
      redirect_to edit_user_path #Redirect the user to the User edition page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a User
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    response = User.find(params[:email],session[:user]) #Retrieve the original user object to delete
    if response[0] #Validate if the response was successfull 
      @user = response[1] #Set the user object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:user_get_error_flash) #Set the error message for the user
      redirect_to users_path #Redirect the user to the users list page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    response2 = @user.delete(session[:user]) #Delete the user object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:user_deletion_success_flash, user: @user.email) #Set the success message for the user
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:user_deletion_error_flash) #Set the error message for the user
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    redirect_to users_path #Redirect the user to the users list page
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  User Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :gender, :nationality, :personality, :yob, :has_personality, :password, :password_confirmation, :contact_number, :locale, :tracking_off, :opt_out_data_collection, :email, :institution_id, :photo, :account_verified)
  end
end




