class OrderController < ApplicationController
  def fetch_order_id
    url = URI('https://dev.api.etnamed.ru/v1/graphql')

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = "{\"query\":\"mutation M {\\n  dmsCreateOrderNumber {\\n    order_id\\n  }\\n}\",\"variables\":{}}"

    response = https.request(request)
    res = JSON.parse(response.read_body)
    res['data']['dmsCreateOrderNumber']['order_id']
  end
end
