#require 'bcrypt'
require 'mw_http_request'

class User 
  #include HttpRequest
  include ActiveModel::Model
  include BCrypt

=begin
  String givenName – given name
  String familyName – family name
  String gender – gender (male/female)
  String nationality - nationality
  String yearOfBirth – year of birth
  Boolean hasPersonality – has personality record.
  String password - password
  String contactNumber – contact number
  **Set <Long> likes – set of things this user likes.**
  boolean accountVerified – has account been verified by email
  boolean trackingOff – phone tracking is off.
  boolean optOutDataCollection – don’t collect data for this user.
  Long institutionId – institution user belongs to.
  String email – user’s institutional email address.
  Iterable<Photo> - user’s photos
=end

  attr_accessor :first_name, :last_name, :gender, :nationality, :personality, :yob, :has_personality, :password, :password_confirmation, :contact_number, :locale, :tracking_off, :opt_out_data_collection, :email, :institution_id, :photo
  attr_reader :id, :account_verified
  
  #validates_presence_of :email, :first_name, :password
  PASSWORD_MIN_LENGHT = 8
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => { :message => ApplicationHelper.validation_error(:email, :presence, nil) }, format: { with: VALID_EMAIL_REGEX, :message => ApplicationHelper.validation_error(:email, :format, "email@mail.com") }
  validates :first_name, :presence => { :message => ApplicationHelper.validation_error(:first_name, :presence, nil) }
  validates :last_name, :presence => { :message => ApplicationHelper.validation_error(:last_name, :presence, nil) }
  validates :password, :presence => { :message => ApplicationHelper.validation_error(:password, :presence, nil) }, length: { minimum: PASSWORD_MIN_LENGHT, :message => ApplicationHelper.validation_error(:email, :length, PASSWORD_MIN_LENGHT.to_s) }
  validates :password_confirmation, :presence => { :message => ApplicationHelper.validation_error(:password_confirmation, :presence, nil) }
  validates :institution_id, :presence => { :message => ApplicationHelper.validation_error(:institution_id, :presence, nil) }
  
attr_accessor :has_personality,  :contact_number, :locale, :tracking_off, :opt_out_data_collection, :email, :institution_id, :photo
  attr_reader :id, :account_verified

=begin
--------------------------------------------------------------------------------------------------------------------
  User object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
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
    @opt_out_data_collection= [:opt_out_data_collection]
    @institution_id = [:institution_id]
    @photo = [:photo]
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

  def authenticate
    reqUrl = "/api/login/"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,self.email, self.password)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == "200"
      return true, @rest_response.body
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end
  
=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Poll
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created poll object
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
                   'likes' => self.likes,
                   'accountVerified' => self.account_verified,
                   'trackingOff' => self.tracking_off,
                   'optOutDataCollection' => self.opt_out_data_collection,
                   'institutionId' self.institution_id,
                   'email' self.email,
                   'Photo' []
                }
      reqUrl = "/api/user/" #Set the request url
      rest_response = MwHttpRequest.http_post_request_unauth(reqUrl,user_req) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        user = User.rest_to_user(rest_response.body) #Turn the response object to a Poll object
        return true, user #Return success
      else
        return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

  def self.all
      [User.new(id: 1, first_name: "Juanito", last_name: "Perez", email:"jperez@mail.com", password:"myPass"), 
      User.new(id: 2, first_name: "Marco", last_name: "Polo", email:"example@railstutorial.org", password:"map"), 
      User.new(id: 3, first_name: "Mega", last_name: "Man", email:"mega@maverick.com", password:"zero", access_granted: true)]
  end


  def update_attributes(attributes = {})
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a User object
  Param 1: Raw object
  Return 1: Transformed User object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_poll(rest_body)
    raw_poll = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
      poll = Poll.new(
        id: raw_poll["nodeId"], 
        question: raw_poll["question"], 
        #answers: raw_poll["answers"],
        answers: raw_poll["answers"].split(','), 
        start_date: Util.epoch_to_date(raw_poll["start"]), #Turn the epoch time to a string start_date, format defined by the locale parameter
        duration: raw_poll["duration"]/60000, #Turn milliseconds to minutes
        owner_id: raw_poll["ownerId"],
        creator_id: raw_poll["creatorId"])  
      return poll #Return the transformed object
  end

end