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

    # puts message
    case user.step
    when "Мой ДМС: 36000руб."
      user.update(program_id: Program.find_by(price: "Мой ДМС: 36000руб.".split.last[0..-5].to_i).id)
      user.save
    end

    case message.text
    when "/start"
      user.step = "start"
      user.save
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
      user.step = "end"
      user.save
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Bye, #{message.from.username}!",
        reply_markup:     kb
      )
    when "#{message.text}"
      user.step = "#{message.text}"
      user.save
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Вы выбрали программу: #{message.text}"
      )
    end
  end
end