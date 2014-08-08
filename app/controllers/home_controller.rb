class HomeController < ApplicationController
  #Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  #Set the default layout for this controller, the views from this controller are available when the user is not looged in
  layout 'logged_off'
  
  def index
    @stylesheet = 'home'
  end
  
  #Call to the sign up action
  def signup
    @stylesheet = 'home'
  	@user = User.new #Set a new user object to be filled by the user form
  end

  def register_successfull
    @stylesheet = 'home'
  end

end
