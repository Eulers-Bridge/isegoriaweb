class Institution

  attr_accessor :name, :state, :campus, :country
  attr_reader :id

  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @state = attributes[:state]
    @campus = attributes[:campus]
    @country = attributes[:country]
  end

  def self.find(id)
  reqUrl = "/api/institution/#{id}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_insitution = JSON.parse(@rest_response.body)
      @institution = Institution.new(
        id: @raw_insitution["institutionId"], 
        name: @raw_insitution["name"],
        state: @raw_insitution["state"],
        campus: @raw_insitution["campus"],
        country: @raw_insitution["country"])
      return true, @institution
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end
end