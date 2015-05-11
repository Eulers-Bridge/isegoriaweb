class TicketsController < ApplicationController
  
  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the tickets from the model by its election id
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
    @page_aux = params[:page] #Retrieve the params from the query string
    @election_id = params[:election_id] #Retrieve the params from the query string
    @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 #Validate if the page_aux param can be parsed as an integer, otherwise set it to cero
    response = Ticket.all(session[:user],@election_id,@page) #Retrieve all the tickets from the model
    if response[0] #Validate if the response was successfull
      @tickets_list = response[1] #Get the tickets list from the response
      @total_pages = response[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < @total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:ticket_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    end 
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new ticket page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
  	@election_id = params[:election_id] #Retrieve the params from the query string
    @ticket = Ticket.new #Set a new ticket object to be filled by the user form
    @ticket.election_id = @election_id #Set the owner election id to the object before its created
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Ticket
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    @ticket = Ticket.new(ticket_params) #Create a new ticket object with the parameters set by the user in the create form
    resp = @ticket.save(session[:user]) #Save the new Ticket object
    if resp[0] #Validate if the response was successfull
      flash[:success] = t(:ticket_creation_success_flash, ticket: @ticket.name) #Set the success message for the user
      redirect_to tickets_path(:election_id =>@ticket.election_id) #Redirect the user to the tickets list page
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Ticket object sent to the model. If so the server would have returned an array with the errors
          flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
        end
        flash[:danger] = t(:ticket_creation_error_flash) #Set the error message for the user
        @ticket = Ticket.new #Reset the Ticket object to an empty one
        redirect_to new_ticket_path #Redirect the user to the Ticket creation page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit ticket page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
    resp = Ticket.find(params[:id],session[:user]) #Retrieve the ticket to update
    if resp[0] #Validate if the response was successfull
    @ticket = resp[1] #Set the ticket object to fill the edit form
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:ticket_get_error_flash) #Set the error message for the user
    redirect_to ticket_path #Redirect the user to edit ticket page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update a Ticket
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
    resp = Ticket.find(params[:id],session[:user]) #Retrieve the original ticket object to update
    if resp[0] #Validate if the response was successfull
    @ticket = resp[1] #Set the ticket object to be updated
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:ticket_get_error_flash) #Set the error message for the user
    redirect_to tickets_path #Redirect the user to the tickets list page
    end
    resp2 = @ticket.update_attributes(ticket_params,session[:user]) #Update the ticket object
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:ticket_modification_success_flash, ticket: @ticket.name) #Set the success message for the user
      redirect_to tickets_path(:election_id =>@ticket.election_id) #Redirect the user to the tickets list page
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Ticket object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
      end
        flash[:danger] = t(:ticket_modification_error_flash) #Set the error message for the user
        redirect_to edit_ticket_path #Redirect the user to the Tickets edition page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a Ticket
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    resp = Ticket.find(params[:id],session[:user]) #Retrieve the original ticket object to update
    if resp[0] #Validate if the response was successfull 
    @ticket = resp[1] #Set the ticket object to be deleted
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:ticket_get_error_flash) #Set the error message for the user
    redirect_to tickets_path(:election_id =>@ticket.election_id) #Redirect the user to the tickets list page
    end
    resp2 = @ticket.delete(session[:user]) #Delete the ticket object
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:ticket_deletion_success_flash, ticket: @ticket.name) #Set the success message for the user
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:ticket_deletion_error_flash) #Set the error message for the user
      end
      redirect_to tickets_path(:election_id =>@ticket.election_id) #Redirect the user to the tickets list page
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Ticket Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
    def ticket_params
      params.require(:ticket).permit(:name, :acronym, :photos, :information, :color, :candidates, :election_id, :number_of_supporters, :picture)
    end
end
