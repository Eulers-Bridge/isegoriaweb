class EventsController < ApplicationController
  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'
  @@images_directory = "UniversityOfMelbourne/Events"

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the events from the model by its owner id
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
    @menu='events' #Set the menu variable
    $title=t(:title_events) #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @page_aux = params[:page] #Retrieve the params from the query string
    @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 #Validate if the page_aux param can be parsed as an integer, otherwise set it to cero
    resp = Event.all(session[:user],@page) #Retrieve all the events from the model
    if resp[0] #Validate if the response was successfull
      @events_list = resp[1] #Get the events list from the response
      @total_pages = resp[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < @total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:event_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new event page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
    @menu='events' #Set the menu variable
    $title=t(:title_new_event)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
	  @event = Event.new #Set a new event object to be filled by the user form
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit event page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
    @menu='events' #Set the menu variable
    $title=t(:title_edit_event)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
	  resp = Event.find(params[:id],session[:user]) #Retrieve the event to update
    if resp[0] #Validate if the response was successfull
      @event = resp[1] #Set the event object to fill the edit form
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:event_get_error_flash) #Set the error message for the user
      redirect_to events_path #Redirect the user to edit event page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Event
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @event = Event.new(event_params) #Create a new event object with the parameters set by the user in the create form
    resp = @event.save(session[:user]) #Save the new Event object
    if resp[0] #Validate if the response was successfull
      @event = resp[1] #Get the event object from the server response
      if !resp[2] #Validate if the photo creation was successfull
        flash[:warning] = t(:event_photo_creation_error_flash) #Set the error message for the user
      end
  	  flash[:success] = t(:event_creation_success_flash, event: @event.name) #Set the success message for the user
      redirect_to events_path #Redirect the user to the events list page
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Event object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:event_creation_error_flash) #Set the error message for the user
   	  @event = Event.new #Reset the Event object to an empty one
   	  redirect_to new_event_path #Redirect the user to the Event creation page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update an Event
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
	  resp = Event.find(params[:id],session[:user]) #Retrieve the original event object to update
    if resp[0] #Validate if the response was successfull
      @event = resp[1] #Set the event object to be updated
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:event_get_error_flash) #Set the error message for the user
      redirect_to events_path #Redirect the user to the events list page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    resp2 = @event.update_attributes(event_params,session[:user]) #Update the candidate object
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:event_modification_success_flash, event: @event.name) #Set the success message for the user
      redirect_to events_path #Redirect the user to the events list page
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Event object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:event_modification_error_flash) #Set the error message for the user
      redirect_to edit_event_path #Redirect the user to the Event edition page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to upload a picture owned by an event
--------------------------------------------------------------------------------------------------------------------------------
=end
  def upload_picture
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    resp = Event.find(params[:id],session[:user]) #Retrieve the original event object to update
    if resp[0] #Validate if the response was successfull
      @event = resp[1] #Set the event object to be updated
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:event_get_error_flash) #Set the error message for the user
      redirect_to :back #Redirect the user to the previous page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    resp2 = @event.upload_picture(event_params,session[:user]) #Upload the picture
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:picture_uploading_success_flash, event: @event.name) #Set the success message for the user
      redirect_to :back #Redirect the user to the previous page
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Photo object sent to the model. If so the server would have returned an array with the errors
          flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:picture_uploading_error_flash)  #Set the error message for the user
      redirect_to :back #Redirect the user to the previous page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a picture owned by an event
--------------------------------------------------------------------------------------------------------------------------------
=end
  def delete_picture
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    resp = Photo.find(params[:id],session[:user]) #Retrieve the original photo object to delete
      if resp[0] #Validate if the response was successfull
      photo = resp[1] #Set the photo object to be deleted
      elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:photo_get_error_flash) #Set the error message for the user
        redirect_to :back #Redirect the user to the previous page
      else 
        return #If not force return to trigger the redirect of the check_session function
      end
      resp2 = photo.delete(session[:user]) #Delete the photo object
      if resp2[0] #Validate if the response was successfull
        flash[:success] = t(:picture_deletion_success_flash, photo: photo.title) #Set the success message for the user
      elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:picture_deletion_error_flash) #Set the error message for the user
        redirect_to :back #Redirect the user to the previous page
      else 
        return #If not force return to trigger the redirect of the check_session function
      end
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete an Event
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    resp = Event.find(params[:id],session[:user]) #Retrieve the original event object to update
    if resp[0] #Validate if the response was successfull
      @event = resp[1] #Set the event object to be deleted
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:event_deletion_error_flash) #Set the error message for the user
      redirect_to events_path #Redirect the user to the events list page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    resp2 = @event.delete(session[:user]) #Delete the event object
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:event_deletion_success_flash, event: @event.name) #Set the success message for the user
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:event_deletion_error_flash) #Set the error message for the user
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
      redirect_to events_path #Redirect the user to the events list page
    rescue #Error Handilng code
      general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Event Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
  def event_params
    params.require(:event).permit(:name, :start_date, :start_time, :end_date, :end_time, :location, :description, :picture, :volunteers, :organizer, :organizer_email, :previous_picture)
  end
end
