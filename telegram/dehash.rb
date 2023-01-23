require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require "uri"
require "json"
require "net/http"

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

def fetch_payment_link(param_insurant, param_insured, order_id, product_id)
  url = URI("https://dev.api.etnamed.ru/v1/graphql")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request["Content-Type"] = "application/json"
  request.body = "{\"query\":\"mutation DMSCreateOrder {\\n  dmsCreateOrder(arg: {back_url: \\\"https://dms.etnamed.ru\\\", insurant: \\\"#{param_insurant}\\\", insured: \\\"#{param_insured}\\\", order_id: \\\"#{order_id}\\\", product_id: #{product_id}, promo_code: \\\"\\\", start_date: \\\"2023-01-30\\\", payment_method: \\\"bank_card\\\", form_guid: \\\"\\\", offer_guid: \\\"\\\"}) {\\n    error\\n    ok\\n    order_id\\n    payment_link\\n    __typename\\n  }\\n}\\n\",\"variables\":{}}"

  response = https.request(request)
  res = JSON.parse(response.read_body)
  res['data']['dmsCreateOrder']['payment_link']
end

hash = {
  id:                         19,
  telegram_id:                276180875,
  step:                       "submitted",
  first_name:                 "Лариса",
  last_name:                  "Шостак",
  father_name:                "Александровна",
  gender:                     "Женский",
  date_of_birth:              "1963-12-01",
  phone:                      "+380679069984",
  email:                      "NaumE64@yandex.ru",
  place_of_birth:             "поселок Старый Крым",
  serial_number_of_passport:  "вс 402923",
  issued:                     "2000-09-23",
  division_code:              "1345",
  issued_by:                  "ГУ МВД",
  registration_address:       "квартал Азовье",
  actual_residence:           "Москва",
  dms_product_id:             1,
  created_at:                 "2023-01-15 11:39:41.122522000 +0000",
  updated_at:                 "2023-01-15 11:41:39.616899000 +0000"
}

insurant = Insurant.first
insured = Insured.first

insurant.update(dms_product_id: 4)

new_insurant = {
  "last_name": "#{insurant.last_name}",
  "first_name": "#{insurant.first_name}",
  "second_name": "#{insurant.second_name}",
  "bithday": "#{insurant.birthday}",
  "passport": "#{insurant.passport}",
  "division_code": "#{insurant.division_code}",
  "division_issuing": "#{insurant.division_issuing}",
  "date_release": "#{insurant.date_release}",
  "birth_place": "#{insurant.birth_place}",
  "phone": "#{insurant.phone}",
  "email": "#{insurant.email}",
  "registration_address": "#{insurant.registration_address}",
  "residence": "#{insurant.residence}"
}

new_insured = [
    {
    "last_name": "#{insured.last_name}",
    "first_name": "#{insured.first_name}",
    "second_name": "#{insured.second_name}",
    "bithday": "#{insured.birthday}",
    "passport": "#{insured.passport}",
    "division_code": "#{insured.division_code}",
    "division_issuing": "#{insured.division_issuing}",
    "date_release": "#{insured.date_release}",
    "birth_place": "#{insured.birth_place}",
    "phone": "#{insured.phone}",
    "email": "#{insured.email}",
    "registration_address": "#{insured.registration_address}",
    "residence": "#{insured.residence}"
  }
]

# puts new_insurant

code_insurant = Base64.strict_encode64(JSON.pretty_generate(new_insurant))
code_insured = Base64.strict_encode64(JSON.pretty_generate(new_insured))

p fetch_payment_link(code_insurant, code_insured, fetch_order_id, insurant.dms_product_id)

# puts "страхуемый:"
# p code_insurant
# puts "застрахованный:"
# p code_insured

# def fetch_info(user)
#   "ФИО: #{user.first_name} #{user.last_name} #{user.father_name}\n"\
#   "Дата рождения: #{user.date_of_birth}\n"\
#   "Пол: #{user.gender}\n"\
#   "Паспорт: #{user.serial_number_of_passport}\n"\
#   "Когда выдан: #{user.issued}\n"\
#   "Код подразделения: #{user.division_code}\n"\
#   "Кем выдан: #{user.issued_by}\n"\
#   "Адрес регистрации: #{user.registration_address}\n"\
#   "Адрес проживания: #{user.actual_residence}\n"\
#   "Контактный телефон: #{user.phone}\n"\
#   "Почта: #{user.email}"
# end

# puts fetch_info(insurant)
