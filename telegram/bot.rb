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
      user.step = "first name"
      user.save
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите имя:"
      )
    when "first name"
      user.first_name = message.text
      user.step = "father name"
      user.save
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите отчество:"
      )
    when "father name"
      user.father_name = message.text
      user.step = "gender"
      user.save
      genders = %w(male female)
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
      user.step = "date_of_birth"
      user.save
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите дату рождения:"
      )
    when "date_of_birth"
      user.date_of_birth = message.text
      user.step = "phone_number"
      user.save
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите номер телефона:"
      )
    when "phone_number"
      user.phone = message.text
      user.step = "email"
      user.save
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите эл. почту:"
      )
    when "email"
      user.email = message.text
      user.step = "sumbit"
      user.save
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Submitted"
      )
    end

    case message.text
    when "/start"
      bot.api.send_message(
        chat_id:    message.chat.id,
        text:       "Hello, #{message.from.username}"
      )
      programs = Program.all
      arr_of_programs = programs.map{ |program| "#{program.title}: #{program.price}руб." }
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard:           arr_of_programs,
        one_time_keyboard:  true
      )
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Choose a program",
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
        user.update(program_id: Program.find_by(
          price: message.text.split.last[0..-5].to_i).id
        )
        bot.api.send_message(
          chat_id:          message.chat.id,
          text:             "Вы выбрали программу: #{message.text}"
        )
        user.step = "last name"
        user.save
        bot.api.send_message(
          chat_id:          message.chat.id,
          text:             "Введите фамилию:"
        )
      end
    end
  end
end