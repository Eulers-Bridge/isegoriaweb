#require 'bcrypt'
require 'mw_http_request'

class User 
  #include HttpRequest
  include ActiveModel::Model
  include BCrypt

  attr_accessor :first_name, :last_name, :email, :gender, :nationality, :personality, :yob, :password,:password_confirmation, :account_type, :position, :ticket_name, :locale
  attr_reader :id, :access_granted, :account_verified
  
  #validates_presence_of :email, :first_name, :password
  PASSWORD_MIN_LENGHT = 8
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => { :message => ApplicationHelper.validation_error(:email, :presence, nil) }, format: { with: VALID_EMAIL_REGEX, :message => ApplicationHelper.validation_error(:email, :format, "email@mail.com") }
  validates :first_name, :presence => { :message => ApplicationHelper.validation_error(:first_name, :presence, nil) }
  validates :password, :presence => { :message => ApplicationHelper.validation_error(:password, :presence, nil) }, length: { minimum: PASSWORD_MIN_LENGHT, :message => ApplicationHelper.validation_error(:email, :length, PASSWORD_MIN_LENGHT.to_s) }
  validates :password_confirmation, :presence => { :message => ApplicationHelper.validation_error(:password_confirmation, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @email = attributes[:email].to_s.downcase
    @gender = attributes[:gender]
    @nationality = attributes[:nationality]
    @personality = 'none'
    @yob = attributes[:yob]
    @account_verified = false
    @password = attributes[:password]
    @password_confirmation = attributes[:password_confirmation]
    @account_type = attributes[:account_type]
    @position = attributes[:position]
    @ticket_name = attributes[:ticket_name]   
    @access_granted = attributes[:access_granted]
  end

  def full_name
  	"#{@first_name} #{@last_name}".strip
  end

  def self.find(id)
  	if id <= 3 && id >=0
  		User.new(id: id)
  	else
  		nil
  	end
  end

  def self.revoke_access(id)
    Rails.logger.debug "***************access revoked to user " + id.to_s
  end

  def self.grant_access(id)
    Rails.logger.debug "***************access granted to user " + id.to_s
  end

  def self.find_by(attributes = {})
  	Rails.logger.debug "Not implemented yet. Keep learning Ruby!"
  end

  def authenticate
  	#gets user info from the Middleware in order to login
    @account_verified = true;
    @locale = "en";
  end

  def self.all
      [User.new(id: 1, first_name: "Juanito", last_name: "Perez", email:"jperez@mail.com", password:"myPass"), 
      User.new(id: 2, first_name: "Marco", last_name: "Polo", email:"example@railstutorial.org", password:"map"), 
      User.new(id: 3, first_name: "Mega", last_name: "Man", email:"mega@maverick.com", password:"zero", access_granted: true)]
  end

  def update_attributes(attributes = {})
  end
  
  def save
    if self.valid?
    	@password_hash = Password.create(@password)
  		Rails.logger.debug "The user is valid!, hashed password: " + @password_hash
        reqUrl = '/api/signUp'

        user = {'email'=>self.email,
                'firstName'=>self.first_name,
                'lastName'=>self.last_name,
                'gender'=>self.last_name,
                'nationality'=>self.nationality,
                'yearOfBirth'=>self.yob,
                'personality'=>self.personality,
                'accountVerified'=>self.account_verified,
                'password'=>@password_hash,
                'institutionId'=>26            
                }
        @rest_response = MwHttpRequest.http_post_request(reqUrl,user)
        Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
        if @rest_response.code == "200"
          return true, @rest_response
        else
          return false, "#{@rest_response.code} #{@rest_response.message}"
        end
  	else
  	  Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
  	end	
  end
end