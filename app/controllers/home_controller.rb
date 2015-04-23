class HomeController < ApplicationController
#Prevent CSRF attacks by raising an exception.
protect_from_forgery with: :exception

  #Set the default layout for this controller, the views from this controller are available when the user is not looged in
  layout 'logged_off'
  
=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect a unlogged user to the sign up page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def signup
    @user = User.new #Set a new user object to be filled with the create form
    response = Country.general_info #Retrieve the countries and institutions catalog
    if response[0] #Validate if the response was successfull
      @countries_catalog = response[1] #Get the countries list from the response
      @countries_js_string = response[2]
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:country_list_error_flash) #Set the error message to the user
      redirect_to root #Redirect the user to the root page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to sign up a new User, created without being logged in
--------------------------------------------------------------------------------------------------------------------------------
=end
  def signup_user
    @user = User.new(user_params) #Create a new User object with the parameters set by the user in the create form
    response = @user.save #Save the new User object
    if response[0] #Validate if the response was successfull
      flash[:success] = t(:home_register_thanks, user: @user.email) #Set the success message for the user
      redirect_to home_register_successfull_path #Redirect the user to the verify email
    else validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(response[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid photo album object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(response[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:user_creation_error_flash) #Set the error message for the user
      redirect_to home_signup_path
    end
  end

  def landing
    render :layout => false
    @stylesheet = 'landing'
  end

  def more_info
    render :layout => false
    @stylesheet = 'more_info'
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  User Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
  def user_params
    params.require(:user).permit(:id, :first_name, :last_name, :gender, :nationality, :personality, :yob, :has_personality, :password, :password_confirmation, :contact_number, :locale, :tracking_off, :opt_out_data_collection, :email, :institution_id, :photo, :account_verified)
  end

end
