class PhotoAlbumsController < ApplicationController

#Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the photo albums from the model by institution
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
	page_aux = params[:page] #Retrieve the params from the query string
    @page = page_aux =~ /\A\d+\z/ ? page_aux.to_i : 0 #Validate if the page_aux param is turnable to an integer, otherwise set it to cero
    response = PhotoAlbum.all(session[:user],@page) #Retrieve all the photo albums from the model
    if response[0] #Validate if the response was successfull
      @photo_albums_list = response[1] #Get the photo albums list from the response
      total_pages = response[3].to_i #Get the total numer of pages from the response
      @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
      @next_page = @page+1 < total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_album_list_error_flash) #Set the error message to the user
      redirect_to error_general_error_path #Redirect the user to the generic error page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new photo album page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
	@photo_album = PhotoAlbum.new #Set a new photo album object to be filled with the create form
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Photo Album
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    @photo_album = PhotoAlbum.new(photo_album_params) #Create a new Photo Album object with the parameters set by the user in the create form
    @photo_album.owner_id = session[:user]['id'] #Set the logged user's id as owner
    @photo_album.creator_id = session[:user]['id'] #Set the logged user's id as creator
    response = @photo_album.save(session[:user]) #Save the new Photo Album object
    if response[0] #Validate if the response was successfull
      flash[:success] = t(:photo_album_creation_success_flash, photo_album: @photo_album.name) #Set the success message for the user
      redirect_to photo_albums_path #Redirect the user to the photo_album list page
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        if(response[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid photo album object sent to the model. If so the server would have returned an array with the errors
          flash[:warning] = Util.format_validation_errors(response[1]) #Set the invalid object message for the user
        end
        flash[:danger] = t(:photo_album_creation_error_flash) #Set the error message for the user
        @photo_album = PhotoAlbum.new #Reset the Photo Album object to an empty one
        redirect_to new_photo_album_path #Redirect the user to the Photo Album creation page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a Photo Album
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    response = PhotoAlbum.find(params[:id],session[:user]) #Retrieve the original photo album object to update
    if response[0] #Validate if the response was successfull 
      @photo_album = response[1] #Set the photo album object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_album_get_error_flash) #Set the error message for the user
      redirect_to photo_albums_path #Redirect the user to the photo_albums list page
    end
    response2 = @photo_album.delete(session[:user]) #Delete the photo_album object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:photo_album_deletion_success_flash, photo_album: @photo_album.name) #Set the success message for the user
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:photo_album_deletion_error_flash) #Set the error message for the user
    end
    redirect_to photo_albums_path #Redirect the user to the photo_albums list page
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit photo album page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
	response = PhotoAlbum.find(params[:id],session[:user]) #Retrieve the photo album to update
    if response[0] #Validate if the response was successfull 
      @photo_album = response[1] #Set the photo album object to fill the edit form
      @page_aux = params[:page] #Retrieve the page number from the url params
      @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 #If none is retrieved, set it to the first page, cero
      response2 = Photo.all_by_album(session[:user],params[:id],@page) #Get the photos uploaded to the photo album
      if response2[0] #Validate if the response was successfull 
        @photos = response2[1] #Set the photos array
        @total_pages = response2[3].to_i #Get the total pages of photos
        @previous_page = @page > 0 ? @page-1 : -1 #Set the previous page index
        @next_page = @page+1 < @total_pages ? @page+1 : -1 #Set the next page index
      elsif validate_authorized_access(response2[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
        flash[:danger] = t(:photo_list_error_flash) #Set the error message for the user
        redirect_to photo_albums_path #Redirect the user to photo_albums index page
      end
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_album_get_error_flash) #Set the error message for the user
      redirect_to photo_album_path #Redirect the user to edit photo_album page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update a Photo Album
--------------------------------------------------------------------------------------------------------------------------------
=end
  def update
	response = PhotoAlbum.find(params[:id],session[:user]) #Retrieve the original photo album object to update
    if response[0] #Validate if the response was successfull 
      @photo_album = response[1] #Set the photo_album object to be updated
    elsif validate_authorized_access(response[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:photo_album_get_error_flash) #Set the error message for the user
      redirect_to photo_albums_path #Redirect the user to the photo albums list page
    end
    response2 = @photo_album.update_attributes(photo_album_params,session[:user]) #Update the photo album object
    if response2[0] #Validate if the response was successfull
      flash[:success] = t(:photo_album_modification_success_flash, photo_album: @photo_album.name) #Set the success message for the user
      redirect_to photo_albums_path #Redirect the user to the photo albums list page
    elsif validate_authorized_access(response2[1])#If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      if(response2[1].kind_of?(Array))#If the response was unsucessful, validate if it was caused by an invalid Photo Album object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(response2[1]) #Set the invalid object message for the user
      end
        flash[:danger] = t(:photo_album_modification_error_flash) #Set the error message for the user
        redirect_to edit_photo_album_path #Redirect the user to the Photo Album edition page
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to upload a Photo owned by a Photo Album
--------------------------------------------------------------------------------------------------------------------------------
=end
  def upload_picture
    resp = PhotoAlbum.find(params[:id],session[:user])
	if resp[0]
	  @photo_album = resp[1]
	elsif validate_authorized_access(resp[1])
	  flash[:danger] = t(:article_get_error_flash)
	  redirect_to :back
	end
	resp2 = @photo_album.upload_picture(photo_album_params,session[:user])
	if resp2[0]
	  flash[:success] = t(:picture_uploading_success_flash, photo_album: @photo_album.name)
	  redirect_to :back
	elsif validate_authorized_access(resp[1])
	  if(resp[1].kind_of?(Array))
        flash[:warning] = Util.format_validation_errors(resp[1])
      end
      flash[:danger] = t(:picture_uploading_error_flash)
      redirect_to :back
	end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a Photo from the Photo Album
--------------------------------------------------------------------------------------------------------------------------------
=end
  def delete_picture
    resp = Photo.find(params[:id],session[:user])
    if resp[0]
      photo = resp[1]
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:photo_get_error_flash)
      redirect_to :back
    end
      resp2 = photo.delete(session[:user])
    if resp2[0]
      flash[:success] = t(:picture_deletion_success_flash, photo: photo.title)
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:picture_deletion_error_flash)
    end
    redirect_to :back
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Photo Album Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
  def photo_album_params
    params.require(:photo_album).permit(:name, :description, :location, :thumbnail, :creator_id, :owner_id, :previous_thumbnail, :picture)
  end

end
