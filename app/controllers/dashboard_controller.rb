class DashboardController < ApplicationController
  def index
    @menu='Dashboard' #Set the menu variable
    $title=t(:title_dashboard)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    # @page_aux = params[:page] #Retrieve the params from the query string
    # @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0  #Validate if the page_aux param can be parsed as an integer, otherwise set it to cero
    # resp = Article.all(session[:user],@page) #Retrieve all the articles from the model
    # if resp[0] #Validate if the response was successfull
    #   @articles_list = resp[1] #Get the article list from the response
    #   @total_pages = resp[3].to_i #Get the total numer of pages from the response
    #   @previous_page = @page > 0 ? @page-1 : -1 #Calculate the previous page number, if we are at the first page, then it will set to minus one
    #   @next_page = @page+1 < @total_pages ? @page+1 : -1 #Calculate the next page number, if we are at the last page, then it will set to minus one
    # elsif validate_authorized_access(resp[1]) #If the response was unsucessful, validate if it was caused by unauthorized access to the app or expired session
    #   flash[:danger] = t(:article_list_error_flash) #Set the error message to the user
    #   redirect_to error_general_error_path #Redirect the user to the generic error page
    # else
    #   return #If not force return to trigger the redirect of the check_session function
    # end
    # rescue #Error Handilng code
    #   general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)  
  end

  def new
    @menu='Dashboard' #Set the menu variable
    $title=t(:title_dashboard)  #Set the title variable
    if !check_session #Validate if the user session is active
      return #If not force return to trigger the redirect of the check_session function
    end
    # @article = Article.new #Set a new article object to be filled by the user form
    # rescue #Error Handilng code
    #   general_error_redirection('Controller: '+params[:controller]+'.'+action_name,$!)
  end
end
