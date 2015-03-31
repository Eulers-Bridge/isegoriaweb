class PollsController < ApplicationController

  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the polls from the model by institution
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
	page_aux = params[:page] #Retrieve the params from the query string
    @page = page_aux =~ /\A\d+\z/ ? page_aux.to_i : 0 #Validate if the page_aux param is turnable to an integer, otherwise set it to cero
    response = Poll.all(session[:user],@page) #Retrieve all the polls from the model
    if response[0] #Validate if the response was successfull
      @polls_list = response[1] #Get the polls list from the response
      total_pages = response[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:poll_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new poll page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
	@poll = Poll.new #Set a new poll object to be filled with the create form
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Poll
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    @poll = Poll.new(poll_params) #Create a new Poll object with the parameters set by the user in the create form
    @poll.owner_id = session[:user]['institutionId'] #Set the logged user's institution as owner
    @poll.creator_id = session[:user]['id'] #Set the logged user as creator
    response = @poll.save(session[:user]) #Save the new Poll object
    if response[0] #Validate if the response was successfull
      flash[:success] = t(:poll_creation_success_flash, poll: @poll.question) #Set the success message for the user
      redirect_to polls_path #Redirect the user to the polls list page
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        if(response[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Poll object sent to the model. If so the server would have returned an array with the errors
          flash[:warning] = Util.format_validation_errors(response[1]) #Set the invalid object message for the user
        end
        flash[:danger] = t(:poll_creation_error_flash) #Set the error message for the user
        @poll = Poll.new #Reset the Poll object to an empty one
        redirect_to new_poll_path #Redirect the user to the Poll creation page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit poll page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
	response = Poll.find(params[:id],session[:user]) #Retrieve the poll to update
    if response[0] #Validate if the response was successfull 
    @poll = response[1] #Set the poll object to fill the edit form
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:poll_get_error_flash) #Set the error message for the user
      redirect_to poll_path #Redirect the user to edit poll page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update a Poll
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
	response = Poll.find(params[:id],session[:user]) #Retrieve the original poll object to update
    if response[0] #Validate if the response was successfull 
      @poll = response[1] #Set the poll object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:poll_get_error_flash) #Set the error message for the user
      redirect_to polls_path #Redirect the user to the polls list page
    end
    response2 = @poll.update_attributes(poll_params,session[:user]) #Update the poll object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:poll_modification_success_flash, poll: @poll.question) #Set the success message for the user
      redirect_to polls_path #Redirect the user to the polls list page
    elsif validate_authorized_access(response2[1])#If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(response2[1].kind_of?(Array))#If the response was unsucessful, validate if it was caused by an invalid Poll object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(response2[1]) #Set the invalid object message for the user
      end
        flash[:danger] = t(:poll_modification_error_flash) #Set the error message for the user
        redirect_to edit_poll_path #Redirect the user to the Poll edition page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a Poll
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    response = Poll.find(params[:id],session[:user]) #Retrieve the original poll object to update
    if response[0] #Validate if the response was successfull 
      @poll = response[1] #Set the poll object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:poll_get_error_flash) #Set the error message for the user
      redirect_to polls_path #Redirect the user to the polls list page
    end
    response2 = @poll.delete(session[:user]) #Delete the poll object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:poll_deletion_success_flash, poll: @poll.question) #Set the success message for the user
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:poll_deletion_error_flash) #Set the error message for the user
    end
    redirect_to polls_path #Redirect the user to the polls list page
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Poll Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
  def poll_params
    params.require(:poll).permit(:question, :start_date, :duration, :answers, :owner_id, :creator_id)
  end
end
