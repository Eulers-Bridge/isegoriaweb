class ElectionsController < ApplicationController

  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the elections from the model by institution
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
    @menu='elections' #Set the menu variable
    $title=t(:title_elections)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
	  page_aux = params[:page] #Retrieve the params from the query string
    @page = page_aux =~ /\A\d+\z/ ? page_aux.to_i : 0 #Validate if the page_aux param is turnable to an integer, otherwise set it to cero
    response = Election.all(session[:user],@page) #Retrieve all the elections from the model
    if response[0] #Validate if the response was successfull
      @elections_list = response[1] #Get the elections list from the response
      total_pages = response[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:election_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new election page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
    @menu='elections' #Set the menu variable
    $title=t(:title_new_election)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
	  @election = Election.new #Set a new election object to be filled with the create form
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end  

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit election page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
    @menu='election' #Set the menu variable
    $title=t(:title_edit_election)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    response = Election.find(params[:id],session[:user]) #Retrieve the election to update
    if response[0] #Validate if the response was successfull 
      @election = response[1] #Set the election object to fill the edit form
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:election_get_error_flash) #Set the error message for the user
      redirect_to election_path #Redirect the user to edit election page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Election
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @election = Election.new(election_params) #Create a new election object with the parameters set by the user in the create form
    @election.institution_id = session[:user]['institutionId'] #Set the logged user's institution id
    response = @election.save(session[:user]) #Save the new Election object
    if response[0] #Validate if the response was successfull
      flash[:success] = t(:election_creation_success_flash, election: @election.title) #Set the success message for the user
      redirect_to elections_path #Redirect the user to the elections list page
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        if(response[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Election object sent to the model. If so the server would have returned an array with the errors
          flash[:warning] = Util.format_validation_errors(response[1]) #Set the invalid object message for the user
        end
        flash[:danger] = t(:election_creation_error_flash) #Set the error message for the user
        @election = Election.new #Reset the Election object to an empty one
        redirect_to new_election_path #Redirect the user to the Election creation page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update an Election
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
	  response = Election.find(params[:id],session[:user]) #Retrieve the original election object to update
    if response[0] #Validate if the response was successfull 
      @election = response[1] #Set the election object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:election_get_error_flash) #Set the error message for the user
      redirect_to elections_path #Redirect the user to the elections list page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    response2 = @election.update_attributes(election_params,session[:user]) #Update the election object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:election_modification_success_flash, election: @election.title) #Set the success message for the user
      redirect_to elections_path #Redirect the user to the elections list page
    elsif validate_authorized_access(response2[1])#If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(response2[1].kind_of?(Array))#If the response was unsucessful, validate if it was caused by an invalid Election object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(response2[1]) #Set the invalid object message for the user
      end
        flash[:danger] = t(:election_modification_error_flash) #Set the error message for the user
        redirect_to edit_election_path #Redirect the user to the Election edition page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete an Election
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    response = Election.find(params[:id],session[:user]) #Retrieve the original election object to update
    if response[0] #Validate if the response was successfull 
      @election = response[1] #Set the election object to be deleted
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:election_get_error_flash) #Set the error message for the user
      redirect_to elections_path #Redirect the user to the elections list page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    response2 = @election.delete(session[:user]) #Delete the election object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:election_deletion_success_flash, election: @election.title) #Set the success message for the user
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:election_deletion_error_flash) #Set the error message for the user
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    redirect_to elections_path #Redirect the user to the elections list page
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Election Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
  def election_params
    params.require(:election).permit(:title, :start_date, :end_date, :start_voting_date, :end_voting_date, :institution_id, :introduction, :process)
  end

end
