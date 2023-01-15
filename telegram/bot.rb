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

    def user_profile_filling(user_profile, bot, message)
      user_profile.update(step: "last name")
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Введите фамилию:"
      )
      bot.listen do |message|
        case user_profile.step
        when "last name"
          user_profile.last_name = message.text
          user_profile.update(step: "first name")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите имя:"
          )
        when "first name"
          user_profile.first_name = message.text
          user_profile.update(step: "father name")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите отчество:"
          )
        when "father name"
          user_profile.father_name = message.text
          user_profile.update(step: "gender")
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
          user_profile.gender = message.text
          user_profile.update(step: "date_of_birth")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите дату рождения:"
          )
        when "date_of_birth"
          user_profile.date_of_birth = message.text
          user_profile.update(step: "phone_number")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите номер телефона:"
          )
        when "phone_number"
          user_profile.phone = message.text
          user_profile.update(step: "email")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите эл. почту:"
          )
        when "email"
          user_profile.email = message.text
          user_profile.update(step: "place_of_birth")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Паспортные данные страхователя\nВведите место рождения:"
          )
        when "place_of_birth"
          user_profile.place_of_birth = message.text
          user_profile.update(step: "serial_number_of_passport")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите серию и номер паспорта:"
          )
        when "serial_number_of_passport"
          user_profile.serial_number_of_passport = message.text
          user_profile.update(step: "issued")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Когда выдан:"
          )
        when "issued"
          user_profile.issued = message.text
          user_profile.update(step: "division_code")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Код подразделения:"
          )
        when "division_code"
          user_profile.division_code = message.text
          user_profile.update(step: "issued_by")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Кем выдан:"
          )
        when "issued_by"
          user_profile.issued_by = message.text
          user_profile.update(step: "registration_address")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Адрес регистрации:"
          )
        when "registration_address"
          user_profile.registration_address = message.text
          user_profile.update(step: "actual_residence")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Адрес фактического места жительства:"
          )
        when "actual_residence"
          user_profile.actual_residence = message.text
          user_profile.update(step: "submitted") and return
        end
      end
    end

    def fetch_info(user)
      "ФИО: #{user.last_name} #{user.first_name} #{user.father_name}\n"\
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

          user_profile_filling(policyholder, bot, message)
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите контакты застрахованного\n(Тот, кто получает полис):"
          )
          user_profile_filling(insurant, bot, message)

          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Страхователь:\n#{fetch_info(policyholder)}"
          )

          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Застрахованный:\n#{fetch_info(insurant)}"
          )
        else
          finish_with_bot(bot, message)
            break
        end
      end
    end
  end
end
