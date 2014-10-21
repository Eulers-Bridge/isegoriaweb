class ErrorController < ApplicationController
#Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  #Set the default layout for this controller, the views from this controller are available when the user is not looged in
  layout 'application'
  
  def general_error
    @stylesheet = 'error'
  end
end
