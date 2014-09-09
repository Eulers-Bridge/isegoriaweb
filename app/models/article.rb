class Article
  include ActiveModel::Model

  attr_accessor :title, :content, :picture
  attr_reader :id, :date, :creator_email, :student_year

  validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  validates :content, :presence => { :message => ApplicationHelper.validation_error(:content, :presence, nil) }
  validates :creator_email, :presence => { :message => ApplicationHelper.validation_error(:creator_email, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  validates :student_year, :presence => { :message => ApplicationHelper.validation_error(:student_year, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @content = attributes[:content]
    @picture = attributes[:picture]
    if !attributes[:creator_email].blank?
      @creator_email = attributes[:creator_email]
    else
      @creator_email = "test@eulersbridge.com"
    end
    if !attributes[:date].blank?
      @date = attributes[:date]#milliseconds passed since epoch Jan/1/1970
    else
      @date = Util.date_to_epoch(Time.now)
    end
    @student_year = Time.now.year.to_s
  end

  def save
    if self.valid?
      Rails.logger.debug "The news article is valid!"
      #@picture = attributes[:picture]
      #directory = "app/assets/images/articles"
      # create the file path
      #path = File.join(directory, @id+File.extname(@picture.original_filename))
      # write the file
      #File.open(path, "wb") { |f| f.write(@picture.read) }
      
      article = {'title'=>self.title,
                'content'=>self.content,
                'picture'=>['article_2.jpg'],
                'date'=> self.date,
                'creatorEmail'=> self.creator_email,
                'institutionId'=> 26          
                }      
      reqUrl = "/api/newsArticle/"

      puts reqUrl
      puts article

      @rest_response = MwHttpRequest.http_post_request(reqUrl,article)
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


  def update_attributes(attributes = {})
    if self.valid?
      Rails.logger.debug "The news article is valid!"
      #@picture = attributes[:picture]
      #directory = "app/assets/images/articles"
      # create the file path
      #path = File.join(directory, @id+File.extname(@picture.original_filename))
      # write the file
      #File.open(path, "wb") { |f| f.write(@picture.read) }
      
      article = {'title'=>attributes[:title],
                'content'=>attributes[:content],
                'picture'=>['article_2.jpg'],
                'date'=>self.date,
                'creatorEmail'=>self.creator_email,
                'institutionId'=>26          
                }      
      reqUrl = "/api/newsArticle/#{self.id}"

      puts reqUrl
      puts article

      @rest_response = MwHttpRequest.http_put_request(reqUrl,article)
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

  def self.all
=begin
      [Article.new(id: 1, title: "Four-star Brazil stroll past Panama, Swiss win", 
        content: "FIFA World Cup™ hosts Brazil strolled to a 4-0 win over Panama in their penultimate warm-up on Tuesday, goals from Neymar, Daniel Alves, Hulk and Willian securing the victory margin.
          After a tentative opening, the Selecao easily saw off limited opponents as Neymar, with his 31st international goal, set the ball rolling, rifling in a free-kick for the opener on the half hour. 
          Alves drove in the second five minutes before the interval and a cheeky Neymar backheel was enough to pave the way for Hulk to dispatch the third early in the second period before Willian put the icing on the cake 17 minutes from time.
          With only Friday's friendly against Serbia to come before the Brazilians meet Croatia in their 12 June World Cup opener in Sao Paulo, 2002 title-winning coach Luiz Felipe Scolari seized the chance to use several second string players.
          Afterwards, he indicated he saw room for further improvement. ""I am still concerned. We are getting better - but we know we have a fair way to go,"" indicated the man who lifted Brazil's fifth Cup in Japan 12 years ago and who now wants to deliver first success on home soil.
          ""The run out was worthwhile but we must up our rhythm and be a lot better for the Croatia game,"" prior to further group games against Mexico and Cameroon.
          Scolari explained the opening minutes of Tuesday's game had concerned him. ""We were a bit off beam in the opening minutes and it could have been different had we been playing a superior opponent. Afterwards, we improved.""", 
        picture: "article_1.jpg", creator:"FIFA 1", date:"2014/05/31"), 
      Article.new(id: 2, title: "Spain's Juanfran ready for Brazil", 
        content: "Spain right-back Juanfran said Tuesday he's recovered from an ankle injury and ""100 per cent"" healthy for his country's FIFA World Cup™ title defence in Brazil.
          ""I don't have any problem, and I am 100 per cent with the team,"" Juanfran said at a press conference in Washington, where Spain will train for two weeks before heading to Brazil.
          The Spain and Atletico Madrid defender suffered a sprained right ankle in the UEFA Champions League final that Atletico lost to Real Madrid on 24 May.", 
        picture: "article_2.jpg", creator:"FIFA 2", date:"2014/06/01"), 
      Article.new(id: 3, title: "Van Gaal: Van Persie will be at full speed", 
        content: "Netherlands coach Louis van Gaal expects Robin van Persie to hit peak fitness for the start of the 2014 FIFA World Cup Brazil™.
          Manchester United striker Van Persie is hoping to get back to his best in Brazil after a frustrating and injury-hit season at Old Trafford. The 30-year-old has scored in friendlies against Ecuador and Ghana in recent weeks as he steps up his recovery from a knee problem.
          Van Persie missed six weeks of action towards the end of United's campaign, returning only for their last three Premier League games. He had been troubled by thigh problems earlier in the season. 
          Van Gaal kept a close eye on Van Persie's most recent rehabilitation having been given permission by United - the club that would later appoint him as manager - to bring him to a training base in Holland.
          The 62-year-old, who will link up with Van Persie full time at United next season, said: ""He is not 100 per cent, but we have two weeks to go. I think he will be 100 per cent. He is coming out of injury but we built him already up in our federation, our medical department.
          It was under the permission of David Moyes. So we could control him, he has worked very hard. Then he played two matches of 20 or 30 minutes and the last match 70 minutes. We did not expect that as the injury was bad.""
          Van Persie is likely to be given another run-out as Holland take on Wales in Amsterdam on Wednesday in their final friendly before flying to Brazil. The Dutch then begin their World Cup campaign against holders Spain in a repeat of the 2010 final in Salvador on 13 June. 
          They face Australia and Chile in their other Group B games.", 
        picture: "article_3.jpg", creator:"FIFA 3", date:"2014/06/03")]
=end
    @newsFeedId = 6276
    reqUrl = "/api/newsArticles/#{@newsFeedId}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_articles_list = JSON.parse(@rest_response.body)
      @articles_list = Array.new
      for article in @raw_articles_list
        puts article
        @articles_list << Article.new(
        id: article["articleId"], 
        title: article["title"], 
        content: article["content"], 
        picture: "article_1.jpg", 
        creator_email: article["creatorEmail"], 
        date: article["date"],
        student_year: article["studentYear"])
      end
      return true, @articles_list
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

  def self.find(id)
=begin
    if id == '1'
      puts "------------------unoooooooooooooooooooo"
      @article = Article.new(id: id, title: "Four-star Brazil stroll past Panama, Swiss win", 
        content: "FIFA World Cup™ hosts Brazil strolled to a 4-0 win over Panama in their penultimate warm-up on Tuesday, goals from Neymar, Daniel Alves, Hulk and Willian securing the victory margin.
          After a tentative opening, the Selecao easily saw off limited opponents as Neymar, with his 31st international goal, set the ball rolling, rifling in a free-kick for the opener on the half hour. 
          Alves drove in the second five minutes before the interval and a cheeky Neymar backheel was enough to pave the way for Hulk to dispatch the third early in the second period before Willian put the icing on the cake 17 minutes from time.
          With only Friday's friendly against Serbia to come before the Brazilians meet Croatia in their 12 June World Cup opener in Sao Paulo, 2002 title-winning coach Luiz Felipe Scolari seized the chance to use several second string players.
          Afterwards, he indicated he saw room for further improvement. ""I am still concerned. We are getting better - but we know we have a fair way to go,"" indicated the man who lifted Brazil's fifth Cup in Japan 12 years ago and who now wants to deliver first success on home soil.
          ""The run out was worthwhile but we must up our rhythm and be a lot better for the Croatia game,"" prior to further group games against Mexico and Cameroon.
          Scolari explained the opening minutes of Tuesday's game had concerned him. ""We were a bit off beam in the opening minutes and it could have been different had we been playing a superior opponent. Afterwards, we improved.""", 
        picture: "article_1.jpg", creator:"FIFA 1", date:"2014/05/31")
    elsif id == '2'
      puts "------------------doooooooooooooooooooos"
      Article.new(id: id, title: "Spain's Juanfran ready for Brazil", 
        content: "Spain right-back Juanfran said Tuesday he's recovered from an ankle injury and ""100 per cent"" healthy for his country's FIFA World Cup™ title defence in Brazil.
          ""I don't have any problem, and I am 100 per cent with the team,"" Juanfran said at a press conference in Washington, where Spain will train for two weeks before heading to Brazil.
          The Spain and Atletico Madrid defender suffered a sprained right ankle in the UEFA Champions League final that Atletico lost to Real Madrid on 24 May.", 
        picture: "article_2.jpg", creator:"FIFA 2", date:"2014/06/01")
    elsif id == '3'
      puts "------------------treeeeeeeeees"
      Article.new(id: id, title: "Van Gaal: Van Persie will be at full speed", 
        content: "Netherlands coach Louis van Gaal expects Robin van Persie to hit peak fitness for the start of the 2014 FIFA World Cup Brazil™.
          Manchester United striker Van Persie is hoping to get back to his best in Brazil after a frustrating and injury-hit season at Old Trafford. The 30-year-old has scored in friendlies against Ecuador and Ghana in recent weeks as he steps up his recovery from a knee problem.
          Van Persie missed six weeks of action towards the end of United's campaign, returning only for their last three Premier League games. He had been troubled by thigh problems earlier in the season. 
          Van Gaal kept a close eye on Van Persie's most recent rehabilitation having been given permission by United - the club that would later appoint him as manager - to bring him to a training base in Holland.
          The 62-year-old, who will link up with Van Persie full time at United next season, said: ""He is not 100 per cent, but we have two weeks to go. I think he will be 100 per cent. He is coming out of injury but we built him already up in our federation, our medical department.
          It was under the permission of David Moyes. So we could control him, he has worked very hard. Then he played two matches of 20 or 30 minutes and the last match 70 minutes. We did not expect that as the injury was bad.""
          Van Persie is likely to be given another run-out as Holland take on Wales in Amsterdam on Wednesday in their final friendly before flying to Brazil. The Dutch then begin their World Cup campaign against holders Spain in a repeat of the 2010 final in Salvador on 13 June. 
          They face Australia and Chile in their other Group B games.", 
        picture: "article_3.jpg", creator:"FIFA 3", date:"2014/06/03")
    else
      puts '--------------veeerch'
      nil
    end
=end
    reqUrl = "/api/newsArticle/#{id}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_article = JSON.parse(@rest_response.body)
      @article = Article.new(
        id: @raw_article["articleId"], 
        title: @raw_article["title"], 
        content: @raw_article["content"], 
        picture: "article_1.jpg", 
        creator_email:@raw_article["creatorEmail"], 
        date: @raw_article["date"],
        student_year: @raw_article["studentYear"])
      return true, @article
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

end