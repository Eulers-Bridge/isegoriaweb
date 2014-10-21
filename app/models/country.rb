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

  def self.general_info
    reqUrl = "/api/general-info"
    @rest_response = MwHttpRequest.http_get_request(reqUrl)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_countries_list = JSON.parse(@rest_response.body)
      @countries_list = Array.new
      for country in @raw_countries_list
        @institutions_list = Array.new
        if(country["universities"] != nil)
          for institution in country["universities"]
            @institutions_list << Institution.new(
              id: institution["institutionId"], 
              name: institution["name"],
              state: institution["state"],
              campus: institution["campus"],
              country: institution["country"])
          end
        end
        @countries_list << Country.new(
        id: country["countryId"], 
        name: country["countryName"], 
        institutions: @institutions_list)
      end
      return true, @countries_list
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

end