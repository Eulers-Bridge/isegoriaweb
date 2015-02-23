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
    resp = Util.get_institutions_catalog
    if resp[0]
      @institutions_catalog = resp[1]["countrys"]
      @aux_string = "{"
      @institutions_catalog.each do |country|
        @aux_string << country['countryId'].to_s + ":["
        country['institutions'].each do |institution|
          @aux_string << "{id:" + institution['institutionId'].to_s + ", name:'" + institution['institutionName'] + "'},"
        end
        @aux_string << "],"
      end
      @aux_string << "}"
      @js_institutions_catalog = @aux_string.gsub('},]','}]').gsub('],}',']}')
      puts '------------------------' + @js_institutions_catalog
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:institutions_list_error_flash)
      redirect_to root
    end
  end

  def register_successfull
    @stylesheet = 'home'
  end

  def landing
    render :layout => false
    @stylesheet = 'landing'
  end

  def more_info
    render :layout => false
    @stylesheet = 'more_info'
  end

end
