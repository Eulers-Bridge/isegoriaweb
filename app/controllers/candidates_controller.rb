class CandidatesController < ApplicationController

  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the candidates from the model by its ticket id
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index

    @menu='candidates' #Set the menu variable
    $title=t(:title_candidates)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @page_aux = params[:page] #Retrieve the params from the query string
    @ticket_id = params[:ticket_id] #Retrieve the params from the query string
    @election_id = params[:election_id] #Retrieve the params from the query string
    @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 #Validate if the page_aux param can be parsed as an integer, otherwise set it to cero
    response_positions = Position.all_no_page(session[:user],@election_id) #Retrieve all the positions from the model to match the candidate position
    if response_positions[0] #Validate if the response was successfull
      @positions_list = response_positions[1] #Get the positions list from the response
    elsif response[1] == '404'
      return
    elsif validate_authorized_access(response_positions[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:position_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    response = Candidate.all(session[:user],@ticket_id,@page) #Retrieve all the candidates from the model
    if response[0] #Validate if the response was successfull
      @candidates_list = response[1] #Get the candidates list from the response
      @total_pages = response[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < @total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:candidate_list_error_flash) #Set the error message to the user
      #redirect_to error_general_error_path #Redirect the user to the generic error page
      @candidates_list = []
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end


=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new candidate page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
    @menu='candidates' #Set the menu variable
    $title=t(:title_new_candidate)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
  	@ticket_id = params[:ticket_id] #Retrieve the params from the query string
    @election_id = params[:election_id] #Retrieve the params from the query string
    @candidate = Candidate.new #Set a new candidate object to be filled by the user form
    response_positions = Position.all_no_page(session[:user],@election_id) #Retrieve all the positions from the model to match the candidate position
    if response_positions[0] #Validate if the response was successfull
      @positions_list = response_positions[1] #Get the positions list from the response
    elsif validate_authorized_access(response_positions[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:position_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Candidate
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @candidate = Candidate.new(candidate_params) #Create a new candidate object with the parameters set by the user in the create form
    @election_id = candidate_params[:election_id] #Retrieve the election id from the form
    @ticket_id = candidate_params[:ticket_id] #Retrieve the ticket id from the form
    resp = @candidate.save(session[:user]) #Save the new Candidate object
    if resp[0] #Validate if the response was successfull
      candidate_id = resp[1].id
      resp2 = @candidate.add_ticket(session[:user],candidate_id.to_s,@ticket_id) #Add the candidate to its ticket
      if resp2[0]
        flash[:success] = t(:candidate_creation_success_flash, candidate: (resp[1].first_name + resp[1].last_name)) #Set the success message for the user
        redirect_to candidates_path :election_id => @election_id, :ticket_id => @ticket_id #Redirect the user to the candidates list page
      elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:candidate_creation_error_flash) #Set the error message for the user
        @candidate = Candidate.new #Reset the Candidate object to an empty one
        redirect_to new_candidate_path :election_id => @election_id, :ticket_id => @ticket_id #Redirect the user to the Candidate creation page
      end
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Candidate object sent to the model. If so the server would have returned an array with the errors
          flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
        end
        flash[:danger] = t(:candidate_creation_error_flash) #Set the error message for the user
        @candidate = Candidate.new #Reset the Candidate object to an empty one
        redirect_to new_candidate_path :election_id => @election_id, :ticket_id => @ticket_id #Redirect the user to the Candidate creation page
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit candidate page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
    @menu='candidates' #Set the menu variable
    $title=t(:title_edit_candidate)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @ticket_id = params[:ticket_id] #Retrieve the params from the query string
    @election_id = params[:election_id] #Retrieve the params from the query string
    resp = Candidate.find(params[:id],session[:user]) #Retrieve the candidate to update
    if resp[0] #Validate if the response was successfull
      @candidate = resp[1] #Set the candidate object to fill the edit form
      response_positions = Position.all_no_page(session[:user],@election_id) #Retrieve all the positions from the model to match the candidate position
      if response_positions[0] #Validate if the response was successfull
        @positions_list = response_positions[1] #Get the positions list from the response
        elsif validate_authorized_access(response_positions[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:position_list_error_flash) #Set the error message to the user
        redirect_to error_general_error_path #Redirect the user to the generic error page
      end
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:candidate_get_error_flash) #Set the error message for the user
      redirect_to candidate_path :election_id => @election_id, :ticket_id => @ticket_id #Redirect the user to edit candidate page
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update a Candidate
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    resp = Candidate.find(params[:id],session[:user]) #Retrieve the original candidate object to update
    @election_id = candidate_params[:election_id] #Retrieve the election id from the form
    @ticket_id = candidate_params[:ticket_id] #Retrieve the ticket id from the form
    if resp[0] #Validate if the response was successfull
    @candidate = resp[1] #Set the candidate object to be updated
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:candidate_get_error_flash) #Set the error message for the user
      redirect_to candidates_path :election_id => @election_id, :ticket_id => @ticket_id  #Redirect the user to the candidates list page
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    resp2 = @candidate.update_attributes(candidate_params,session[:user]) #Update the candidate object
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:candidate_modification_success_flash, candidate: (resp2[1].first_name + resp2[1].last_name)) #Set the success message for the user
      redirect_to candidates_path :election_id => @election_id, :ticket_id => @ticket_id  #Redirect the user to the candidates list page
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Candidate object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:candidate_modification_error_flash) #Set the error message for the user
      redirect_to edit_candidate_path :election_id => @election_id, :ticket_id => @ticket_id  #Redirect the user to the Candidate edition page
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a Candidate
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @election_id = params[:election_id] #Retrieve the election id from the form
    @ticket_id = params[:ticket_id] #Retrieve the ticket id from the form
    resp = Candidate.find(params[:id],session[:user]) #Retrieve the original candidate object to update
    if resp[0] #Validate if the response was successfull
    @candidate = resp[1] #Set the candidate object to be deleted
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:candidate_get_error_flash) #Set the error message for the user
      redirect_to candidates_path :election_id => @election_id, :ticket_id => @ticket_id  #Redirect the user to the candidates list page
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    resp2 = @candidate.delete(session[:user]) #Delete the candidate object
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:candidate_deletion_success_flash, candidate: (@candidate.first_name + @candidate.last_name)) #Set the success message for the user
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:candidate_deletion_error_flash) #Set the error message for the user
    else
      return #If not force return to trigger the redirect of the check_session function
    end
    redirect_to candidates_path :election_id => @election_id, :ticket_id => @ticket_id  #Redirect the user to the candidates list page
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Candidate Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
    def candidate_params
      params.require(:candidate).permit(:information, :policy_statement, :photos, :first_name, :last_name, :user_id, :position_id, :ticket_id, :election_id)
    end
end
