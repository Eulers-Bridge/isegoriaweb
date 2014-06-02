require 'bcrypt'

class User
  include ActiveModel::Model
  include BCrypt

  attr_accessor :first_name, :last_name, :username, :email, :password,:password_confirmation, :account_type, :position, :ticket_name, :locale
  attr_reader :id, :created, :modified, :access_granted, :verified_email
  #validates_presence_of :email, :first_name, :password
  PASSWORD_MIN_LENGHT = 8
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => { :message => ApplicationHelper.validation_error(:email, :presence, nil) }, format: { with: VALID_EMAIL_REGEX, :message => ApplicationHelper.validation_error(:email, :format, "email@mail.com") }
  validates :username, :presence => { :message => ApplicationHelper.validation_error(:username, :presence, nil) }
  validates :first_name, :presence => { :message => ApplicationHelper.validation_error(:first_name, :presence, nil) }
  validates :password, :presence => { :message => ApplicationHelper.validation_error(:password, :presence, nil) }, length: { minimum: PASSWORD_MIN_LENGHT, :message => ApplicationHelper.validation_error(:email, :length, PASSWORD_MIN_LENGHT.to_s) }
  validates :password_confirmation, :presence => { :message => ApplicationHelper.validation_error(:password_confirmation, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @username = attributes[:username]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @email = attributes[:email].to_s.downcase
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
    looger.debug "***************access revoked to user " + id.to_s
  end

  def self.grant_access(id)
    looger.debug "***************access granted to user " + id.to_s
  end

  def self.find_by(attributes = {})
  	looger.debug "Not implemented yet. Keep learning Ruby!"
  end

  def authenticate
  	#gets user info from the Middleware in order to login
    @verified_email = true;
    @locale = "en";
  end

  def self.all
      [User.new(id: 1, firts_name: "Juanito", last_name: "Perez", username: "jperez", email:"jperez@mail.com", password:"myPass"), 
      User.new(id: 2, firts_name: "Marco", last_name: "Polo", username: "mpolo", email:"example@railstutorial.org", password:"map"), 
      User.new(id: 3, firts_name: "Mega", last_name: "Man", username: "rockman", email:"mega@maverick.com", password:"zero", access_granted: true)]
  end

  def update_attributes(attributes = {})
  end
  
  def save  
    if self.valid?
    	@password_hash = Password.create(@password)
  		logger.debug "The user is valid!, hashed password: " + @password_hash
      true
  	else
  		puts self.errors.full_messages
  	end	
  end

  public
  def destroy
  end

  public
  def self.testReq
    require 'net/http'

  #url = URI.parse('http://eulersbridge.com:8080/dbInterface-0.1.0/general-info')
  #req = Net::HTTP::Get.new(url.path)
  #res = Net::HTTP.start(url.host, url.port) {|http|
  #  http.request(req)
  #  }
  #  puts res.body
end

end