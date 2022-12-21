require "uri"
require "json"
require "net/http"

url = URI("https://dev.api.etnamed.ru/v1/graphql")

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Content-Type"] = "application/json"
request.body = "{\"query\":\"{\\n  dms_products {\\n created_at\\n    id\\n    medical_sum\\n    name\\n    price\\n    program\\n    uid\\n    updated_at\\n  }\\n}\",\"variables\":{}}"

response = https.request(request)
res = JSON.parse(response.read_body)
res['data']['dms_products'].each { |hash| p hash['program']}

# "#{p hash['name']} #{p hash['price'][0]['price'].to_s}"