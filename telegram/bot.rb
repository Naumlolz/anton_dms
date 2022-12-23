require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'

token = "5982315763:AAFJcUzIQN7ufbw2VgyOEfwkez67aIJ8lak"

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if !User.exists?(telegram_id: message.from.id)
      user = User.create(telegram_id: message.from.id, name: message.from.first_name)
    else
      user = User.find_by(telegram_id: message.from.id)
    end

    case user.step
    when "last name"
      user.last_name = message.text
      user.update(step: "first name")
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите имя:"
      )
    when "first name"
      user.first_name = message.text
      user.update(step: "father name")
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите отчество:"
      )
    when "father name"
      user.father_name = message.text
      user.update(step: "gender")
      genders = %w(Мужской Женский)
      each_gender = genders.map{ |gender| gender }
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard:           each_gender,
        one_time_keyboard:  true
      )
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Выберите пол:",
        reply_markup:     markup
      )
    when "gender"
      user.gender = message.text
      user.update(step: "date_of_birth")
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите дату рождения:"
      )
    when "date_of_birth"
      user.date_of_birth = message.text
      user.update(step: "phone_number")
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите номер телефона:"
      )
    when "phone_number"
      user.phone = message.text
      user.update(step: "email")
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите эл. почту:"
      )
    when "email"
      user.email = message.text
      user.update(step: "email")
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Submitted"
      )
    end

    case message.text
    when "/start"
      bot.api.send_message(
        chat_id:    message.chat.id,
        text:       "Добровольное медицинское страхование.\nДМС - правильный выбор для тех, кто ценит своё время сервис и качество.\nЕсли Вам потребуется медицинская помощь, Вы сможете попасть к врачу в удобное время, быстро сдать анализы и пройти лечение"
      )
      dms_products = DmsProduct.all
      arr_of_dms_products = dms_products.map{ |dms_product| "#{dms_product.name}" }
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard:           arr_of_dms_products,
        one_time_keyboard:  true
      )
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Программы ДМС:",
        reply_markup:     markup
      )
    when "/end"
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Bye, #{message.from.username}!",
        reply_markup:     kb
      )
    when message.text
      if message.text.start_with?("Мой ДМС")
        user.update(dms_product_id: DmsProduct.find_by(name: message.text).id)
        bot.api.send_message(
          chat_id:          message.chat.id,
          text:             "Вы выбрали программу: #{message.text}"
        )
        user.update(step: "last name")
        bot.api.send_message(
          chat_id:          message.chat.id,
          text:             "Введите фамилию:"
        )
      end
    end
  end
end