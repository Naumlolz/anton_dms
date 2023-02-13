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

#  kb = [
#         Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Go to Google', url: 'https://google.com'),
#         Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Touch me', callback_data: 'touch'),
#       ]
#       markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

#         reply_markup: markup

TRAVEL_TYPE = ["Спокойный отдых", "Активный отдых", "Экстремальный отдых"]

kb = [
  Telegram::Bot::Types::InlineKeyboardButton.new(text: "Спокойный отдых", callback_data: TRAVEL_TYPE[0]),
  Telegram::Bot::Types::InlineKeyboardButton.new(text: "Активный отдых", callback_data: TRAVEL_TYPE[1]),
  Telegram::Bot::Types::InlineKeyboardButton.new(text: "Экстремальный отдых", callback_data: TRAVEL_TYPE[2])
]
markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
bot.api.send_message(chat_id: message.chat.id, 
  text: 'Выберите тип отдыха: 
  Спокойный отдых: Застрахованный может участвовать в спортивных развлечениях и занятиях активными видами деятельности,' +
  'но не может заниматься спортом на любительском или профессиональном уровне, ' +
  'а также подготавливаться или участвовать в любого рода соревнованиях.
  Активный отдых: Застрахованный может заниматься спортом на любительском уровне, ' +
  'исключая подготовку и участие в соревнованиях любого рода, как и любой профессиональный спорт.
  Экстремальный отдых: Застрахованный может активно отдыхать и заниматься спортом, ' +
  'однако необходимо исключить любые профессиональные соревнования или подготовку к ним.', 
  reply_markup: markup)
