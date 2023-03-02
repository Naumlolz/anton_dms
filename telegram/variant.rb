require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require "uri"
require "json"
require "net/http"
require "date"

url = URI("https://dev.api.etnamed.ru/v1/graphql")

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Content-Type"] = "application/json"
request.body = "{\"query\":\"query dms_prod{\\n  dms_products {\\n    created_at\\n    id\\n    medical_sum\\n    name\\n    price\\n    program\\n    uid\\n    updated_at\\n    city {\\n      active\\n      created_at\\n      id\\n      name\\n      position\\n    }\\n    city_id\\n    file_program_path\\n  }\\n}\",\"variables\":{}}"

response = https.request(request)
res = JSON.parse(response.read_body)
res['data']['dms_products'].each do |hash|
  p hash['city']['name']
  # unless City.exists?(id: hash['city']['id'])
  #   City.create(
  #     name: hash['city']['name'],
  #     active: hash['city']['active'],
  #     position: hash['city']['position']
  #   )
  #   unless DmsProduct.exists?(id: hash['id'])
  #     DmsProduct.create(
  #       medical_sum: hash['medical_sum'],
  #       name:        hash['name'],
  #       price:       hash['price'],
  #       program:     hash['program'],
  #       uid:         hash['uid'],
  #       city_id:     hash['city_id'],
  #       file_program_path: hash['file_program_path']
  #     )
  #   end
  # end
end