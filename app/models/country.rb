class Country

  attr_accessor :name, :institutions
  attr_reader :id

  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @institutions = attributes[:institutions]
  end

  def self.find(id)
  reqUrl = "/api/country/#{id}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_country = JSON.parse(@rest_response.body)
      @institutions_list = Array.new
      if(@raw_country["universities"] != nil)
        for institution in @raw_country["universities"]
          @institutions_list << Institution.new(
            id: institution["institutionId"], 
            name: institution["name"],
            state: institution["state"],
            campus: institution["campus"],
            country: institution["country"])
        end
      end
      @country = Country.new(
        id: @raw_country["countryId"], 
        name: @raw_country["countryName"], 
        institutions: @institutions_list)
      return true, @country
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

  def self.all
    reqUrl = "/api/countrys"
    @rest_response = MwHttpRequest.http_get_request(reqUrl)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_countries_list = JSON.parse(@rest_response.body)
      @countries_list = Array.new
      for country in @raw_countries_list
        @countries_list << Country.new(
        id: country["countryId"], 
        name: country["countryName"], 
        institutions: nil)
      end
      return true, @countries_list
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end


=begin
--------------------------------------------------------------------------------------------------------------------
  Function to get Countries and its Institutions
  Return if successful: 1.execution result(true), 
                        2.array with its respective countries
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.general_info
    Rails.logger.debug "Call to country.general_info"
    reqUrl = "/api/general-info" #Build the request url
    rest_response = MwHttpRequest.http_get_request_unauth(reqUrl)
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}" #Make the GET request to the Middleware server
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_countries_list = JSON.parse(rest_response.body) #Get the country info from the response and normalize it to an array to handle it
      countries_list = Array.new #Initialize an empty array for the countries objects
      for country in raw_countries_list["countrys"] #Iterate through the countries array 
        institutions_list = Array.new #Initialize an empty array for the institutions objects at each country
        if(country["institutions"] != nil) #Validate if there are any institutions at the country object
          for institution in country["institutions"] #Iterate through the institutions array and add a new Institution object for each
            institutions_list << Institution.new( 
              id: institution["institutionId"], 
              name: institution["institutionName"])
          end
        end
        #Add a country object for each one at the array
        countries_list << Country.new(
          id: country["countryId"], 
          name: country["countryName"], 
          institutions: institutions_list)
      end

      countries_js_string = "{"
      countries_list.each do |country|
        countries_js_string << country.id.to_s + ":["
        country.institutions.each do |institution|
          countries_js_string << "{id:" + institution.id.to_s + ", name:'" + institution.name + "'},"
        end
        countries_js_string << "],"
      end
      countries_js_string << "}"
      countries_js_string = countries_js_string.gsub('},]','}]').gsub('],}',']}')

      return true, countries_list, countries_js_string #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #rReturn error
    end
  end

  def self.all(user, page)
    Rails.logger.debug "Call to article.all"
    institutionId = user['institutionId'] #Retrieve the institution id from the logged user
    page = page != nil ? page : 0 #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/newsArticles/#{institutionId}?page=#{page}&pageSize=10" #Build the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])#Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_articles_list = JSON.parse(rest_response.body) #Get the country info from the response and normalize it to an array to handle it
      total_articles = raw_articles_list['totalElements'] #Retrieve the total articles number for pagination
      total_pages = raw_articles_list['totalPages'] #Retrieve the total number of pages for pagination
      articles_list = Array.new #Initialize an empty array for the articles
      for raw_article in raw_articles_list['foundObjects'] #For each article received from the server
        article = Article.rest_to_article(raw_article.to_json) #Turn an article to json format
        articles_list << article #Add it to the articles array
      end
      return true, articles_list, total_articles, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

end