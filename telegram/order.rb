require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require "uri"
require "json"
require "net/http"
require "date"


p OrderController.new.fetch_order_id

# date = Date.today + 1.weeks
# p date

# url = URI("https://dev.api.etnamed.ru/v1/graphql")

# https = Net::HTTP.new(url.host, url.port)
# https.use_ssl = true

# request = Net::HTTP::Post.new(url)
# request["Content-Type"] = "application/json"
# request.body = "{\"query\":\"mutation M {\\n  dmsCreateOrderNumber {\\n    order_id\\n  }\\n}\",\"variables\":{}}"

# response = https.request(request)
# res = JSON.parse(response.read_body)
# p res['data']['dmsCreateOrderNumber']['order_id']
