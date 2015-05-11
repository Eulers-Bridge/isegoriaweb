class PositionsController < ApplicationController
  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the positions from the model by election
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
	  page_aux = params[:page] #Retrieve the params from the query string
	  @election_id = params[:election_id] #Retrieve the params from the query string
    @page = page_aux =~ /\A\d+\z/ ? page_aux.to_i : 0 #Validate if the page_aux param is turnable to an integer, otherwise set it to cero
    response = Position.all(session[:user],@election_id,@page) #Retrieve all the positions from the model
    if response[0] #Validate if the response was successfull
      @positions_list = response[1] #Get the positions list from the response
      total_pages = response[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
      @position = Position.new #Set a new position object to be filled by the user    
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:position_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Position
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    @position = Position.new(position_params) #Create a new Position object with the parameters set by the user in the create form
    Rails.logger.debug @position.to_s
    response = @position.save(session[:user]) #Save the new Position object
    if response[0] #Validate if the response was successfull
      flash[:success] = t(:position_creation_success_flash, position: @position.name) #Set the success message for the user
      redirect_to positions_path(:election_id =>@position.election_id) #Redirect the user to the positions list page
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        if(response[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Position object sent to the model. If so the server would have returned an array with the errors
          flash[:warning] = Util.format_validation_errors(response[1]) #Set the invalid object message for the user
        end
        flash[:danger] = t(:position_creation_error_flash) #Set the error message for the user
        @position = Position.new #Reset the Position object to an empty one
        redirect_to positions_path(:election_id =>@position.election_id) #Redirect the user to the positions list page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update a Position
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
	response = Position.find(params[:id],session[:user]) #Retrieve the original position object to update
    if response[0] #Validate if the response was successfull 
      @position = response[1] #Set the position object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:poll_get_error_flash) #Set the error message for the user
      redirect_to positions_path(:election_id =>@position.election_id) #Redirect the user to the positions list page
    end
    response2 = @position.update_attributes(position_params,session[:user]) #Update the position object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:position_modification_success_flash, position: @position.name) #Set the success message for the user
      redirect_to positions_path(:election_id =>@position.election_id) #Redirect the user to the positions list page
    elsif validate_authorized_access(response2[1])#If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(response2[1].kind_of?(Array))#If the response was unsucessful, validate if it was caused by an invalid Poll object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(response2[1]) #Set the invalid object message for the user
      end
        flash[:danger] = t(:position_modification_error_flash) #Set the error message for the user
        redirect_to positions_path(:election_id =>@position.election_id) #Redirect the user to the positions list page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a Position
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    response = Position.find(params[:id],session[:user]) #Retrieve the original position object to update
    if response[0] #Validate if the response was successfull 
      @position = response[1] #Set the position object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:position_get_error_flash) #Set the error message for the user
      redirect_to positions_path(:election_id =>@position.election_id) #Redirect the user to the positions list page
    end
    response2 = @position.delete(session[:user]) #Delete the position object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:position_deletion_success_flash, position: @position.name) #Set the success message for the user
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:position_deletion_error_flash) #Set the error message for the user
    end
    redirect_to positions_path(:election_id =>@position.election_id) #Redirect the user to the positions list page
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Position Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
  def position_params
    params.require(:position).permit(:name, :description, :election_id)
  end

end
