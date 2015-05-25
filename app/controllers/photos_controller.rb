class PhotosController < ApplicationController
  
  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the photos from the model by its owner user
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
    @menu='photos' #Set the menu variable
    $title=t(:title_photos)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @page_aux = params[:page] #Retrieve the params from the query string
    @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 #Validate if the page_aux param can be parsed as an integer, otherwise set it to cero
    response = Photo.all(session[:user],@page) #Retrieve all the photos from the model
    if response[0] #Validate if the response was successfull
      @photos_list = response[1] #Get the photos list from the response
      @total_pages = response[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < @total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end 
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new photo page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
    @menu='photos' #Set the menu variable
    $title=t(:title_new_photo)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @photo = Photo.new #Set a new photo object to be filled by the user form
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit photo page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
    @menu='photos' #Set the menu variable
    $title=t(:title_edit_photo)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    resp = Photo.find(params[:id],session[:user]) #Retrieve the photo to update
    if resp[0] #Validate if the response was successfull
    @photo = resp[1] #Set the photo object to fill the edit form
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_get_error_flash) #Set the error message for the user
      redirect_to photo_path #Redirect the user to edit photo page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Photo
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    @photo = Photo.new(photo_params) #Create a new photo object with the parameters set by the user in the create form
    @photo.owner_id = session[:user]['id'] #Set the logged user's id as owner
    resp = @photo.save(session[:user],nil) #Save the new Photo object
    if resp[0] #Validate if the response was successfull
      flash[:success] = t(:photo_creation_success_flash, photo: @photo.title) #Set the success message for the user
      redirect_to photos_path #Redirect the user to the photos list page
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Photo object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:photo_creation_error_flash) #Set the error message for the user
      @photo = Photo.new #Reset the Photo object to an empty one
      redirect_to new_photo_path #Redirect the user to the Photo creation page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update a Photo
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    resp = Photo.find(params[:id],session[:user]) #Retrieve the original photo object to update
    if resp[0] #Validate if the response was successfull
    @photo = resp[1] #Set the photo object to be updated
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_get_error_flash) #Set the error message for the user
      redirect_to photos_path #Redirect the user to the photos list page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    resp2 = @photo.update_attributes(photo_params,session[:user],nil) #Update the photo object
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:photo_modification_success_flash, photo: @photo.title) #Set the success message for the user
      redirect_to photos_path #Redirect the user to the photos list page
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Photo object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
      end
        flash[:danger] = t(:photo_modification_error_flash) #Set the error message for the user
        redirect_to edit_photo_path #Redirect the user to the Photos edition page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a Photo
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    resp = Photo.find(params[:id],session[:user]) #Retrieve the original photo object to update
    if resp[0] #Validate if the response was successfull 
    @photo = resp[1] #Set the photo object to be deleted
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_get_error_flash) #Set the error message for the user
      redirect_to photos_path #Redirect the user to the photos list page
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    resp2 = @photo.delete(session[:user]) #Delete the photo object
    if resp2[0] #Validate if the response was successfull
      flash[:success] = t(:photo_deletion_success_flash, photo: @photo.title) #Set the success message for the user
    elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_deletion_error_flash) #Set the error message for the user
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
      redirect_to photos_path #Redirect the user to the photos list page
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Photo Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
    def photo_params
      params.require(:photo).permit(:title, :description, :file, :owner_id, :date, :previous_picture)
    end
end
