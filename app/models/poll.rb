class Poll
  include ActiveModel::Model

  attr_accessor :question, :date, :answers, :picture, :duration
  attr_reader :id

  validates :question, :presence => { :message => ApplicationHelper.validation_error(:question, :presence, nil) }
  validates :answers, :presence => { :message => ApplicationHelper.validation_error(:answers, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  validates :duration, :presence =>{ :message => ApplicationHelper.validation_error(:duration, :presence, nil) }
  validates :picture, :presence => { :message => ApplicationHelper.validation_error(:picture, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @question = attributes[:question]
    @date = attributes[:date]
    @answers = attributes[:answers]
    @picture = attributes[:picture]
    @duration = attributes[:duration]
  end

  def save
    if self.valid?
      Rails.logger.debug "The poll question is valid!"
      #directory = "app/assets/images/polls"
      # create the file path
      #path = File.join(directory, @id+File.extname(@picture.original_filename))
      # write the file
      #File.open(path, "wb") { |f| f.write(@picture.read) }
      
=begin      article = {'title'=>self.title,
                'content'=>self.content,
                'picture'=>['article_2.jpg'],
                'date'=> self.date,
                'creatorEmail'=> self.creator_email,
                'institutionId'=> 26          
                }      
      reqUrl = "/api/newsArticle/"

      @rest_response = MwHttpRequest.http_post_request(reqUrl,article)
      Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
      if @rest_response.code == "200"
        return true, @rest_response
      else
        return false, "#{@rest_response.code} #{@rest_response.message}"
      end
=end
      return true
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
    end
  end

  def update_attributes(attributes = {})
    @question = attributes[:question]
    @date = attributes[:date]
    @options = attributes[:options]
    @picture = attributes[:picture]
    if self.valid?
      Rails.logger.debug "The poll question is valid!"
      directory = "app/assets/images/polls"
      # create the file path
      path = File.join(directory, @id+File.extname(@picture.original_filename))
      # write the file
      File.open(path, "wb") { |f| f.write(@picture.read) }
      true#call to the update method of the DB
    else
      Rails.logger.debug self.errors.full_messages
      false
    end
  end

  def self.find(id)
    if id =='1'
      Poll.new(id: 1, question: "Who will win the FIFA World Cup?", date:"2014/05/31", answers: ["Brasil","Germany","Ecuador"])
    elsif id == '2'
      Poll.new(id: 2, question: "Who will win Wimbledon?", date:"2014/06/01", answers: ["Novak Djokovik","Roger Federer","Rafael Nadal"])
    elsif id == '3'
      Poll.new(id: 3, question: "What was first, the hen or the egg?", date:"2014/06/02", answers: ["The hen","The egg","Neither"])
    else
      nil
    end 
=begin
    reqUrl = "/api/poll/#{id}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_poll = JSON.parse(@rest_response.body)
      @poll = Poll.new(
        id: @raw_poll["pollId"], 
        question: @raw_poll["question"], 
        answers: @raw_poll["answers"], 
        picture: "poll_1.jpg", 
        date:@raw_poll["date"], 
        duration: @raw_poll["duration"])
      return true, @poll
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
=end


  end

  def self.all
      [Poll.new(id: 1, question: "Who will win the FIFA World Cup?", date:"2014/05/31", answers: ["Brasil","Germany","Ecuador"]), 
      Poll.new(id: 2, question: "Who will win Wimbledon?", date:"2014/06/01", answers: ["Novak Djokovik","Roger Federer","Rafael Nadal"]),
      Poll.new(id: 3, question: "What was first, the hen or the egg?", date:"2014/06/02", answers: ["The hen","The egg","Neither"])]
  end

end