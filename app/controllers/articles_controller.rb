class ArticlesController < ApplicationController

  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'
  @@images_directory = "UniversityOfMelbourne/NewsArticles"

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to retrieve and list all the articles from the model by its owner id
--------------------------------------------------------------------------------------------------------------------------------
=end
  def index
    @menu='articles' #Set the menu variable
    $title=t(:title_articles)  #Set the title variable
    if !check_session #Validate if the user session is active
	    return #If not force return to trigger the redirect of the check_session function
	  end
	  @page_aux = params[:page] #Retrieve the params from the query string
	  @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0  #Validate if the page_aux param can be parsed as an integer, otherwise set it to cero
	  resp = Article.all(session[:user],@page) #Retrieve all the articles from the model
	  if resp[0] #Validate if the response was successfull
	    @articles_list = resp[1] #Get the article list from the response
	    @total_pages = resp[3].to_i #Get the total numer of pages from the response
	    @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
	    @next_page = @page+1 < @total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
	  elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
	    flash[:danger] = t(:article_list_error_flash) #Set the error message to the user
	    redirect_to error_general_error_path #Redirect the user to the generic error page
	  else
      return #If not force return to trigger the redirect of the check_session function
    end	
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the new article page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def new
    @menu='articles' #Set the menu variable
    $title=t(:title_new_article)  #Set the title variable
    if !check_session #Validate if the user session is active
	    return #If not force return to trigger the redirect of the check_session function
	  end
	  @article = Article.new #Set a new article object to be filled by the user form
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to redirect the user to the edit article page
--------------------------------------------------------------------------------------------------------------------------------
=end
  def edit
    @menu='articles' #Set the menu variable
    $title=t(:title_edit_article)  #Set the title variable
    if !check_session #Validate if the user session is active
  	  return #If not force return to trigger the redirect of the check_session function
	  end
	  resp = Article.find(params[:id],session[:user]) #Retrieve the article to update
	  if resp[0] #Validate if the response was successfull
	    @article = resp[1] #Set the article object to fill the edit form
	  elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
	    flash[:danger] = t(:article_get_error_flash) #Set the error message for the user
	    redirect_to articles_path #Redirect the user to edit article page
	  else 
      return #If not force return to trigger the redirect of the check_session function
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to create a new Article
--------------------------------------------------------------------------------------------------------------------------------
=end
  def create
    if !check_session #Validate if the user session is active
	    return #If not force return to trigger the redirect of the check_session function
	  end
	  @article = Article.new(article_params) #Create a new article object with the parameters set by the user in the create form
	  @article.creator_email = session[:user]['email'] #Set the creator email to the looged user email
	  resp = @article.save(session[:user]) #Save the new Article object
	  if resp[0] #Validate if the response was successfull
	    @article = resp[1] #Get the article object from the server response
	    if !resp[2] #Validate if the photo creation was successfull
	      flash[:warning] = t(:article_photo_creation_error_flash) #Set the error message for the user
	    end
	    flash[:success] = t(:article_creation_success_flash, article: @article.title) #Set the success message for the user
	    redirect_to articles_path #Redirect the user to the articles list page
	  elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
	    if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Article object sent to the model. If so the server would have returned an array with the errors
        flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
      end
      flash[:danger] = t(:article_creation_error_flash) #Set the error message for the user
      @article = Article.new  #Reset the Article object to an empty one
      redirect_to new_article_path #Redirect the user to the Article creation page
	  else 
      return #If not force return to trigger the redirect of the check_session function
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to update an Article
--------------------------------------------------------------------------------------------------------------------------------
=end
def update
  if !check_session #Validate if the user session is active
    return #If not force return to trigger the redirect of the check_session function
  end
  resp = Article.find(params[:id],session[:user]) #Retrieve the original article object to update
  if resp[0] #Validate if the response was successfull
    @article = resp[1] #Set the article object to be updated
  elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
    flash[:danger] = t(:article_get_error_flash) #Set the error message for the user
    redirect_to articles_path #Redirect the user to the articles list page
  else 
    return #If not force return to trigger the redirect of the check_session function
  end
  resp2 = @article.update_attributes(article_params,session[:user]) #Update the article object
  if resp2[0] #Validate if the response was successfull
    flash[:success] = t(:article_modification_success_flash, article: @article.title) #Set the success message for the user
    redirect_to articles_path #Redirect the user to the articles list page
  elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
    if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Article object sent to the model. If so the server would have returned an array with the errors
      flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
    end
    flash[:danger] = t(:article_modification_error_flash) #Set the error message for the user
    redirect_to edit_article_path #Redirect the user to the Article edition page
  else 
    return #If not force return to trigger the redirect of the check_session function
  end
end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to upload a picture owned by an article
--------------------------------------------------------------------------------------------------------------------------------
=end
def upload_picture
  if !check_session #Validate if the user session is active
    return #If not force return to trigger the redirect of the check_session function
  end
  resp = Article.find(params[:id],session[:user]) #Retrieve the original article object to update
  if resp[0] #Validate if the response was successfull
	  @article = resp[1] #Set the article object to be updated
  elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
    flash[:danger] = t(:article_get_error_flash) #Set the error message for the user
	  redirect_to :back #Redirect the user to the previous page
  end
  resp2 = @article.upload_picture(article_params,session[:user]) #Upload the picture
  if resp2[0] #Validate if the response was successfull
  	flash[:success] = t(:picture_uploading_success_flash, article: @article.title) #Set the success message for the user
    redirect_to :back #Redirect the user to the previous page
  elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
  	if(resp[1].kind_of?(Array)) #If the response was unsucessful, validate if it was caused by an invalid Photo object sent to the model. If so the server would have returned an array with the errors
      flash[:warning] = Util.format_validation_errors(resp[1]) #Set the invalid object message for the user
    end
    flash[:danger] = t(:picture_uploading_error_flash) #Set the error message for the user
   	redirect_to :back #Redirect the user to the previous page
  else 
    return #If not force return to trigger the redirect of the check_session function
  end
end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a picture owned by an article
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
  end
  resp2 = photo.delete(session[:user]) #Delete the photo object
  if resp2[0] #Validate if the response was successfull
    flash[:success] = t(:picture_deletion_success_flash, photo: photo.title) #Set the success message for the user
    redirect_to :back #Redirect the user to the previous page
  elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
    flash[:danger] = t(:picture_deletion_error_flash) #Set the error message for the user
    redirect_to :back #Redirect the user to the previous page
  else 
    return #If not force return to trigger the redirect of the check_session function
  end
end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Function to delete a Article
--------------------------------------------------------------------------------------------------------------------------------
=end
  def destroy
    if !check_session #Validate if the user session is active
	  return #If not force return to trigger the redirect of the check_session function
	end
	resp = Article.find(params[:id],session[:user]) #Retrieve the original article object to update
	if resp[0] #Validate if the response was successfull
	  @article = resp[1] #Set the article object to be deleted
	elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
	  flash[:danger] = t(:article_get_error_flash) #Set the error message for the user
	  redirect_to articles_path #Redirect the user to the articles list page
	else 
      return #If not force return to trigger the redirect of the check_session function
    end
	resp2 = @article.delete(session[:user]) #Delete the article object
	if resp2[0] #Validate if the response was successfull
	  flash[:success] = t(:article_deletion_success_flash, article: @article.title) #Set the success message for the user
	elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
      flash[:danger] = t(:article_deletion_error_flash) #Set the error message for the user
    else 
      return #If not force return to trigger the redirect of the check_session function
    end
    redirect_to articles_path #Redirect the user to the articles list page
  end

=begin
--------------------------------------------------------------------------------------------------------------------------------
  Article Model parameters definition
--------------------------------------------------------------------------------------------------------------------------------
=end
  private
  def article_params
    params.require(:article).permit(:title, :content, :picture, :creator_email, :date, :previous_picture)
  end
end
