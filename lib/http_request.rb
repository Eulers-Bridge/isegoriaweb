module HttpRequest
  #Function that makes a Post request to the server with a json object as body
  def http_post_request (reqUrl, jsonObject)
    require 'json'
    require 'net/http'
    puts 'http request module-------------------------------------------------------'
    uri = URI.parse('http://www.eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri)
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    json_data = jsonObject.to_json
    http.request(request, json_data)
  end
end