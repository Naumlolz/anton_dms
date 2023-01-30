require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require "uri"
require "json"
require "net/http"
require 'date'

def fetch_order_id
  url = URI("https://dev.api.etnamed.ru/v1/graphql")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request["Content-Type"] = "application/json"
  request.body = "{\"query\":\"mutation M {\\n  dmsCreateOrderNumber {\\n    order_id\\n  }\\n}\",\"variables\":{}}"

  response = https.request(request)
  res = JSON.parse(response.read_body)
  res['data']['dmsCreateOrderNumber']['order_id']
end

# def fetch_payment_link(param_insurant, param_insured, order_id, product_id)
#   url = URI("https://dev.api.etnamed.ru/v1/graphql")

#   https = Net::HTTP.new(url.host, url.port)
#   https.use_ssl = true

#   request = Net::HTTP::Post.new(url)
#   request["Content-Type"] = "application/json"
#   request.body = "{\"query\":\"mutation DMSCreateOrder {\\n  dmsCreateOrder(arg: {back_url: \\\"https://dms.etnamed.ru\\\", insurant: \\\"#{param_insurant}\\\", insured: \\\"#{param_insured}\\\", order_id: \\\"#{order_id}\\\", product_id: #{product_id}, promo_code: \\\"\\\", start_date: \\\"2023-02-09\\\", payment_method: \\\"bank_card\\\", form_guid: \\\"\\\", offer_guid: \\\"\\\"}) {\\n    error\\n    ok\\n    order_id\\n    payment_link\\n    __typename\\n  }\\n}\\n\",\"variables\":{}}"

#   response = https.request(request)
#   res = JSON.parse(response.read_body)
#   res['data']['dmsCreateOrder']['payment_link']
# end

insured = Insured.first

insurant = Insurant.first

insurant.update(dms_product_id: 2)
insured.update(dms_product_id: 2)


new_insurant = {
  "last_name": "#{insurant.last_name}",
  "first_name": "#{insurant.first_name}",
  "second_name": "#{insurant.second_name}",
  "bithday": "#{insurant.birthday}",
  "passport": "#{insurant.passport}",
  "division_code": "#{insurant.division_code}",
  "division_issuing": "#{insurant.division_issuing}",
  "date_release": "#{insurant.date_release}",
  "gender": "#{insurant.gender}",
  "birth_place": "#{insurant.birth_place}",
  "phone": "#{insurant.phone}",
  "email": "#{insurant.email}",
  "registration_address": "#{insurant.registration_address}",
  "residence": "#{insurant.residence}"
}

# puts new_insurant

new_insured = [
    {
    "last_name": "#{insured.last_name}",
    "first_name": "#{insured.first_name}",
    "second_name": "#{insured.second_name}",
    "bithday": "#{insured.birthday}",
    "passport": "#{insured.passport}",
    "division_code": "#{insured.division_code}",
    "division_issuing": "#{insured.division_issuing}",
    "gender": "#{insurant.gender}",
    "date_release": "#{insured.date_release}",
    "birth_place": "#{insured.birth_place}",
    "phone": "#{insured.phone}",
    "email": "#{insured.email}",
    "registration_address": "#{insured.registration_address}",
    "residence": "#{insured.residence}"
  }
]

code_insurant = Base64.strict_encode64(JSON.pretty_generate(new_insurant))
code_insured = Base64.strict_encode64(JSON.pretty_generate(new_insured))

fetch_order_id

insurant.dms_product_id

start_date = Date.today + 1.weeks

p PaymentLinkController.new.fetch_payment_link(code_insurant, code_insured, fetch_order_id, insurant.dms_product_id, start_date)
