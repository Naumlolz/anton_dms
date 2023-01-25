require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require "uri"
require "json"
require "net/http"
require "date"

insureds = Insured.all

new_insureds = []

insureds.each do |insured|
  new_insureds.push(
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
  )
end

# p insureds.size

p new_insureds.size
