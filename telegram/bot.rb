require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'

token = "5982315763:AAFJcUzIQN7ufbw2VgyOEfwkez67aIJ8lak"

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if !User.exists?(telegram_id: message.from.id)
      user = User.create(telegram_id: message.from.id, name: message.from.first_name)
      policyholder = PolicyHolder.create(telegram_id: message.from.id)
      insurant = Insurant.create(telegram_id: message.from.id)
    else
      user = User.find_by(telegram_id: message.from.id)
      policyholder = PolicyHolder.create(telegram_id: message.from.id)
      insurant = Insurant.create(telegram_id: message.from.id)
    end

    def finish_with_bot(bot, message)
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Bye, #{message.from.username}!",
        reply_markup:     kb
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
      finish_with_bot(bot, message)
    when message.text
      if message.text.start_with?("Мой ДМС")
        program_name = message.text
        user.update(dms_product_id: DmsProduct.find_by(name: message.text).id)
        current_dms_product = user.dms_product
        current_dms_product_options = ["Прочесть описание", "Выбрать программу"]
        option_to_choose = current_dms_product_options.map { |option| option }
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard:           option_to_choose,
          one_time_keyboard:  true
        )
        bot.api.send_message(
          chat_id:          message.chat.id,
          text:             "Выберите опцию:",
          reply_markup:     markup
        )
        
      end
      bot.listen do |message|
        if message.text == "Прочесть описание"
          current_dms_product_titles = current_dms_product.program.map { |program| "#{program['title']}"}
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
            keyboard:           current_dms_product_titles,
            one_time_keyboard:  true
          )
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Услуги:",
            reply_markup:     markup
          )
          bot.listen do |hint|
            if current_dms_product_titles.include?(hint.text)
              current_dms_product.program.each do |program|
                if program["title"] == hint.text
                  program["description"].each do |program_item|
                    bot.api.send_message(
                      chat_id:          hint.chat.id,
                      text:             program_item["items"],
                    )
                  end
                end
              end
            else
              finish_with_bot(bot, hint)
              break
            end
          end
        elsif message.text == "Выбрать программу"
          policyholder.update(dms_product_id: DmsProduct.find_by(name: program_name).id)
          insurant.update(dms_product_id: DmsProduct.find_by(name: program_name).id)
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Вы выбрали программу: #{program_name}.\nВведите контакты страхователя\n(Тот, кто оплачивает полис)"
          )
          policyholder.update(step: "last name")
          insurant.update(step: "last name")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите фамилию:"
          )
          bot.listen do |message|
            case policyholder.step
            when "last name"
              policyholder.last_name = message.text
              policyholder.update(step: "first name")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите имя:"
              )
            when "first name"
              policyholder.first_name = message.text
              policyholder.update(step: "father name")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите отчество:"
              )
            when "father name"
              policyholder.father_name = message.text
              policyholder.update(step: "gender")
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
              policyholder.gender = message.text
              policyholder.update(step: "date_of_birth")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите дату рождения:"
              )
            when "date_of_birth"
              policyholder.date_of_birth = message.text
              policyholder.update(step: "phone_number")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите номер телефона:"
              )
            when "phone_number"
              policyholder.phone = message.text
              policyholder.update(step: "email")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите эл. почту:"
              )
            when "email"
              policyholder.email = message.text
              policyholder.update(step: "place_of_birth")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Паспортные данные страхователя\n(Тот, кто оплачивает полис)\nВведите место рождения:"
              )
            when "place_of_birth"
              policyholder.place_of_birth = message.text
              policyholder.update(step: "serial_number_of_passport")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите серию и номер паспорта:"
              )
            when "serial_number_of_passport"
              policyholder.serial_number_of_passport = message.text
              policyholder.update(step: "issued")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Когда выдан:"
              )
            when "issued"
              policyholder.issued = message.text
              policyholder.update(step: "division_code")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Код подразделения:"
              )
            when "division_code"
              policyholder.division_code = message.text
              policyholder.update(step: "issued_by")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Кем выдан:"
              )
            when "issued_by"
              policyholder.issued_by = message.text
              policyholder.update(step: "registration_address")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Адрес регистрации:"
              )
            when "registration_address"
              policyholder.registration_address = message.text
              policyholder.update(step: "actual_residence")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Адрес фактического места жительства:"
              )
            when "actual_residence"
              policyholder.actual_residence = message.text
              policyholder.update(step: "submitted")
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите контакты застрахованного\n(Тот, кто получает полис):"
              )
            end

            case insurant.step
            when "last name"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите фамилию:"
              )
              insurant.last_name = message.text
              insurant.update(step: "first name")
            when "first name"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите имя:"
              )
              insurant.first_name = message.text
              insurant.update(step: "father name")
            when "father name"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите отчество:"
              )
              insurant.father_name = message.text
              insurant.update(step: "gender")
            when "gender"
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
              insurant.gender = message.text
              insurant.update(step: "date_of_birth")
            when "date_of_birth"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите дату рождения:"
              )
              insurant.date_of_birth = message.text
              insurant.update(step: "phone_number")
            when "phone_number"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите номер телефона:"
              )
              insurant.phone = message.text
              insurant.update(step: "email")
            when "email"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите эл. почту:"
              )
              insurant.email = message.text
              insurant.update(step: "place_of_birth")
            when "place_of_birth"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Паспортные данные застрахованного\n(Тот, кто получает полис)\nВведите место рождения:"
              )
              insurant.place_of_birth = message.text
              insurant.update(step: "serial_number_of_passport")
            when "serial_number_of_passport"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите серию и номер паспорта:"
              )
              insurant.serial_number_of_passport = message.text
              insurant.update(step: "issued")
            when "issued"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Когда выдан:"
              )
              insurant.issued = message.text
              insurant.update(step: "division_code")
            when "division_code"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Код подразделения:"
              )
              insurant.division_code = message.text
              insurant.update(step: "issued_by")
            when "issued_by"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Кем выдан:"
              )
              insurant.issued_by = message.text
              insurant.update(step: "registration_address")
            when "registration_address"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Адрес регистрации:"
              )
              insurant.registration_address = message.text
              insurant.update(step: "actual_residence")
            when "actual_residence"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Адрес фактического места жительства:"
              )
              insurant.actual_residence = message.text
              insurant.update(step: "submitted")
            when "submitted"
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "submitted"
              )
            end
          end
        else
          finish_with_bot(bot, message)
            break
        end
      end
    end
  end
end
