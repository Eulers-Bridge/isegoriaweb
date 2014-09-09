module MwHttpRequest
  #Function that makes a POST request to the server with a json object as body
  def self.http_post_request (reqUrl, jsonObject)
    require 'json'
    require 'net/http'
    puts 'CAll to the http POST request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri)
    request.basic_auth 'greg.newitt@unimelb.edu.au', 'test123'
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    json_data = jsonObject.to_json
    http.request(request, json_data)
  end

  #Function that makes a GET request to the server
  def self.http_get_request (reqUrl)
    require 'net/http'
    puts 'Call to the http GET request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri)
    request.basic_auth 'greg.newitt@unimelb.edu.au', 'test123'
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')

    http.request(request)
  end

  #Function that makes a PUT request to the server with a json object as body
  def self.http_put_request (reqUrl, jsonObject)
    require 'json'
    require 'net/http'
    puts 'Call to the http PUT request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Put.new(uri)
    request.basic_auth 'greg.newitt@unimelb.edu.au', 'test123'
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    json_data = jsonObject.to_json
    http.request(request, json_data)
  end

  #Function that makes a DELETE request to the server
  def self.http_delete_request (reqUrl)
    require 'net/http'
    puts 'Call to the http DELETE request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Delete.new(uri)
    request.basic_auth 'greg.newitt@unimelb.edu.au', 'test123'
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    http.request(request)
  end
end