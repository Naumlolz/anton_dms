require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require "uri"
require "json"
require "net/http"

url = URI("https://dev.api.etnamed.ru/v1/graphql")

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
# p insurant

def fetch_info(user)
  "ФИО: #{user.first_name} #{user.last_name} #{user.father_name}\n"\
  "Дата рождения: #{user.date_of_birth}\n"\
  "Пол: #{user.gender}\n"\
  "Паспорт: #{user.serial_number_of_passport}\n"\
  "Когда выдан: #{user.issued}\n"\
  "Код подразделения: #{user.division_code}\n"\
  "Кем выдан: #{user.issued_by}\n"\
  "Адрес регистрации: #{user.registration_address}\n"\
  "Адрес проживания: #{user.actual_residence}\n"\
  "Контактный телефон: #{user.phone}\n"\
  "Почта: #{user.email}"
end

puts fetch_info(insurant)
