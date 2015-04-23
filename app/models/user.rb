#require 'bcrypt'
require 'mw_http_request'

class User 
  include ActiveModel::Model
  include BCrypt

  attr_accessor :first_name, :last_name, :gender, :nationality, :personality, :yob, :has_personality, :password, :password_confirmation, :contact_number, :locale, :tracking_off, :opt_out_data_collection, :email, :institution_id, :photos
  #attr_reader :id 
  attr_reader:account_verified

  PASSWORD_MIN_LENGHT = 8
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => { :message => ApplicationHelper.validation_error(:email, :presence, nil) }, format: { with: VALID_EMAIL_REGEX, :message => ApplicationHelper.validation_error(:email, :format, "email@mail.com") }
  validates :first_name, :presence => { :message => ApplicationHelper.validation_error(:first_name, :presence, nil) }
  validates :last_name, :presence => { :message => ApplicationHelper.validation_error(:last_name, :presence, nil) }
  validates :password, :presence => { :message => ApplicationHelper.validation_error(:password, :presence, nil) }, length: { minimum: PASSWORD_MIN_LENGHT, :message => ApplicationHelper.validation_error(:email, :length, PASSWORD_MIN_LENGHT.to_s) }
  validates :password_confirmation, :presence => { :message => ApplicationHelper.validation_error(:password_confirmation, :presence, nil) }
  validates :institution_id, :presence => { :message => ApplicationHelper.validation_error(:institution_id, :presence, nil) }

=begin
--------------------------------------------------------------------------------------------------------------------
  User object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    #@id = attributes[:id]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @email = attributes[:email].to_s.downcase
    @gender = attributes[:gender]
    @nationality = attributes[:nationality]
    @yob = attributes[:yob]
    @password = attributes[:password]
    @password_confirmation = attributes[:password_confirmation] 
    @contact_number = attributes[:contact_number] 
    @tracking_off = attributes[:tracking_off]
    @opt_out_data_collection= attributes[:opt_out_data_collection]
    @institution_id = attributes[:institution_id]
    @photo = attributes[:photo]
    @account_verified = attributes[:account_verified]
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to get a User full name 
  Return if successful: 1.The first and last name concatenated
--------------------------------------------------------------------------------------------------------------------
=end
  def full_name
  	"#{@first_name} #{@last_name}".strip
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to login a user to the app
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.response from the server
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def authenticate
    reqUrl = "/api/login/"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,self.email, self.password)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == "200"
      return true, @rest_response.body
    else
      return false, "#{@rest_response.code}", "#{@rest_response.message}"
    end
  end
  
=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new User
  Return if successful: 1.execution result(true), 
                        2.created user object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save
    Rails.logger.debug "Call to users.save"
    if self.valid? #Validate if the User object is valid
      @password_hash = Password.create(@password)
      Rails.logger.debug "The user is valid!, hashed password: " + @password_hash
      #Create a raw user object
      user_req = { 'givenName'=> self.first_name,
                   'familyName'=> self.last_name,
                   'gender'=> self.gender,
                   'nationality' => self.nationality,
                   'yearOfBirth' => self.yob,
                   'password' => self.password,
                   'contactNumber' => self.contact_number,
                   'accountVerified' => self.account_verified ==1 ? true : false,
                   'trackingOff' => self.tracking_off == 1 ? true : false,
                   'optOutDataCollection' => self.opt_out_data_collection = 1 ? true : false,
                   'institutionId' => self.institution_id,
                   'email' => self.email,
                   'photos' => []
                }
      reqUrl = "/api/signUp" #Set the request url
      rest_response = MwHttpRequest.http_post_request_unauth(reqUrl,user_req) #Make the POST call to the server with the required parameters
      #rest_response = MwHttpRequest.http_post_request(reqUrl,user_req,'greg.newitt@unimelb.edu.au','test123')
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        user_resp = User.rest_to_user(rest_response.body) #Turn the response object to a Poll object
        return true, user_resp #Return success
      else
        return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to delete a User
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.server response
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def delete(user)
    Rails.logger.debug "Call to user.delete"
    reqUrl = "/api/user/#{self.email}" #Set the request url
    rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password']) #Make the DELETE request to the server with the required parameters
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
      return true, rest_response #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to update a User
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated user object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {},user)
    Rails.logger.debug "Call to user.update_attributes"
    if self.valid? #Validate if the User object is valid
      Rails.logger.debug "The user is valid!"
      
      #Create a raw user object
      user_obj = { 'givenName'=> atributes[:first_name],
                   'familyName'=> atributes[:last_name],
                   'gender'=> atributes[:gender],
                   'nationality' => atributes[:nationality],
                   'yearOfBirth' => atributes[:yob],
                   'password' => atributes[:password],
                   'contactNumber' => atributes[:contact_number],
                   'accountVerified' => atributes[:account_verified] ==1 ? true : false,
                   'trackingOff' => atributes[:tracking_off] == 1 ? true : false,
                   'optOutDataCollection' => atributes[:opt_out_data_collection] = 1 ? true : false,
                   'institutionId' => atributes[:institution_id],
                   'email' => self.email,
                   'photos' => self.photos
                }
      reqUrl = "/api/user/#{self.email}" #Set the request url
      rest_response = MwHttpRequest.http_put_request(reqUrl,user_obj,user['email'],user['password']) #Make the PUT request to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        user_resp = User.rest_to_user(rest_response.body) #Turn the response object to a User object
        return true, user_resp #Return success
      else
        return false, "#{rest_response.code}", "#{rest_response.message}"#Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

  def self.all(user, page)
      return true,
      [User.new(id: 1, first_name: "Juanito", last_name: "Perez", email:"jperez@mail.com", password:"myPass", account_verified: true), 
      User.new(id: 2, first_name: "Marco", last_name: "Polo", email:"example@railstutorial.org", password:"map", account_verified: false), 
      User.new(id: 3, first_name: "Mega", last_name: "Man", email:"mega@maverick.com", password:"zero", account_verified: true)]
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve a user by its id
  Param 1: user id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.User object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(email,user)
    Rails.logger.debug "Call to user.find"
    reqUrl = "/api/user/#{email}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      user_resp = User.rest_to_user(rest_response.body) #Turn the response object to a User object
      return true, user_resp #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a User object
  Param 1: Raw object
  Return 1: Transformed User object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_user(rest_body)
    raw_user = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
      user = User.new(
        #id:raw_user["nodeId"],
        account_verified:raw_user["accountVerified"],
        first_name:raw_user["givenName"], 
        last_name:raw_user["familyName"], 
        gender:raw_user["gender"], 
        nationality:raw_user["nationality"],
        yob:raw_user["yearOfBirth"], 
        has_personality:raw_user["hasPersonality"], 
        password:raw_user["password"],
        contact_number:raw_user["contactNumber"],
        tracking_off:raw_user["trackingOff"], 
        opt_out_data_collection:raw_user["optOutDataCollection"],
        email:raw_user["email"], 
        institution_id:raw_user["institutionId"])
      return user #Return the transformed object
  end

end