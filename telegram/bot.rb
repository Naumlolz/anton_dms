require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require "uri"
require "json"
require "net/http"
require "date"

token = "5982315763:AAFJcUzIQN7ufbw2VgyOEfwkez67aIJ8lak"

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if !User.exists?(telegram_id: message.from.id)
      user = User.create(telegram_id: message.from.id, name: message.from.first_name)
      insured = Insured.create(telegram_id: message.from.id)
      insurant = Insurant.create(telegram_id: message.from.id)
    else
      user = User.find_by(telegram_id: message.from.id)
      insured = Insured.create(telegram_id: message.from.id)
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
          user_profile.update(step: "second name")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите отчество:"
          )
        when "second name"
          user_profile.second_name = message.text
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
          user_profile.update(step: "birthday")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите дату рождения:"
          )
        when "birthday"
          user_profile.birthday = message.text
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
          user_profile.update(step: "birth_place")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Паспортные данные страхователя\nВведите место рождения:"
          )
        when "birth_place"
          user_profile.birth_place = message.text
          user_profile.update(step: "passport")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите серию и номер паспорта:"
          )
        when "passport"
          user_profile.passport = message.text
          user_profile.update(step: "date_release")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Когда выдан:"
          )
        when "date_release"
          user_profile.date_release = message.text
          user_profile.update(step: "division_code")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Код подразделения:"
          )
        when "division_code"
          user_profile.division_code = message.text
          user_profile.update(step: "division_issuing")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Кем выдан:"
          )
        when "division_issuing"
          user_profile.division_issuing = message.text
          user_profile.update(step: "registration_address")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Адрес регистрации:"
          )
        when "registration_address"
          user_profile.registration_address = message.text
          user_profile.update(step: "residence")
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Адрес фактического места жительства:"
          )
        when "residence"
          user_profile.residence = message.text
          user_profile.update(step: "submitted") and return
        end
      end
    end

    def fetch_info(user)
      "ФИО: #{user.last_name} #{user.first_name} #{user.second_name}\n"\
      "Дата рождения: #{user.birthday}\n"\
      "Пол: #{user.gender}\n"\
      "Паспорт: #{user.passport}\n"\
      "Когда выдан: #{user.date_release}\n"\
      "Код подразделения: #{user.division_code}\n"\
      "Кем выдан: #{user.division_issuing}\n"\
      "Адрес регистрации: #{user.registration_address}\n"\
      "Адрес проживания: #{user.residence}\n"\
      "Контактный телефон: #{user.phone}\n"\
      "Почта: #{user.email}"
    end

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

    def fetch_payment_link(param_insurant, param_insured, order_id, product_id, start_date)
      url = URI("https://dev.api.etnamed.ru/v1/graphql")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/json"
      request.body = "{\"query\":\"mutation DMSCreateOrder {\\n  dmsCreateOrder(arg: {back_url: \\\"https://dms.etnamed.ru\\\", insurant: \\\"#{param_insurant}\\\", insured: \\\"#{param_insured}\\\", order_id: \\\"#{order_id}\\\", product_id: #{product_id}, promo_code: \\\"\\\", start_date: \\\"#{start_date}\\\", payment_method: \\\"bank_card\\\", form_guid: \\\"\\\", offer_guid: \\\"\\\"}) {\\n    error\\n    ok\\n    order_id\\n    payment_link\\n    __typename\\n  }\\n}\\n\",\"variables\":{}}"

      response = https.request(request)
      res = JSON.parse(response.read_body)
      res['data']['dmsCreateOrder']['payment_link']
    end

    def final_submit_keyboard(bot, message)
      variants = ['Добавить застрахованное лицо', 'Перейти к оплате'].map { |variant| variant }
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard:           variants,
        one_time_keyboard:  true
      )
      bot.api.send_message(
        chat_id:          message.chat.id,
        text:             "Выберите действие:",
        reply_markup:     markup
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
          insured.update(dms_product_id: DmsProduct.find_by(name: program_name).id)
          insurant.update(dms_product_id: DmsProduct.find_by(name: program_name).id)
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Вы выбрали программу: #{program_name}.\nВведите контакты страхователя\n(Тот, кто оплачивает полис)"
          )

          user_profile_filling(insurant, bot, message)

          each_variant = %w(Да Нет).map { |variant| variant }
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
            keyboard:           each_variant,
            one_time_keyboard:  true
          )
          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Введите контакты застрахованного\n(Тот, кто получает полис):\nСовпадает со страхователем?",
            reply_markup:     markup
          )
          bot.listen do |message|
            if message.text == 'Да'
              insured.update(
                first_name: insurant.first_name,
                last_name: insurant.last_name,
                second_name: insurant.second_name,
                birthday: insurant.birthday,
                gender: insurant.gender,
                passport: insurant.passport,
                division_code: insurant.division_code,
                division_issuing: insurant.division_issuing,
                date_release: insurant.date_release,
                birth_place: insurant.birth_place,
                phone: insurant.phone,
                email: insurant.email,
                registration_address: insurant.registration_address,
                residence: insurant.residence
              )
              break
            elsif message.text == 'Нет'
              bot.api.send_message(
                chat_id:          message.chat.id,
                text:             "Введите контакты застрахованного\n(Тот, кто получает полис):"
              )
              user_profile_filling(insured, bot, message)
              break
            end
          end

          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Страхователь:\n#{fetch_info(insurant)}"
          )

          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             "Застрахованный:\n#{fetch_info(insured)}"
          )

          insureds = []
          insureds.push(insured)

          final_submit_keyboard(bot, message)

          bot.listen do |message|
            if message.text == 'Добавить застрахованное лицо'
              new_insured = Insured.create(telegram_id: message.from.id, dms_product_id: insurant.dms_product_id)
              user_profile_filling(new_insured, bot, message)
              insureds.push(new_insured)
              final_submit_keyboard(bot, message)
            elsif message.text == 'Перейти к оплате'
              break
            end
          end

          # p insureds
          new_insureds = []

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

          insureds.each do |new_insured|
            new_insureds.push(
                {
                "last_name": "#{new_insured.last_name}",
                "first_name": "#{new_insured.first_name}",
                "second_name": "#{new_insured.second_name}",
                "bithday": "#{new_insured.birthday}",
                "passport": "#{new_insured.passport}",
                "division_code": "#{new_insured.division_code}",
                "division_issuing": "#{new_insured.division_issuing}",
                "gender": "#{new_insured.gender}",
                "date_release": "#{new_insured.date_release}",
                "birth_place": "#{new_insured.birth_place}",
                "phone": "#{new_insured.phone}",
                "email": "#{new_insured.email}",
                "registration_address": "#{new_insured.registration_address}",
                "residence": "#{new_insured.residence}"
              }
            )
          end

          new_insureds

          fetch_order_id
          code_insurant = Base64.strict_encode64(JSON.pretty_generate(new_insurant))
          code_insured = Base64.strict_encode64(JSON.pretty_generate(new_insureds))
          start_date = Date.today + 1.weeks

          # p fetch_payment_link(code_insurant, code_insured, fetch_order_id, insurant.dms_product.id, start_date)

          bot.api.send_message(
            chat_id:          message.chat.id,
            text:             fetch_payment_link(code_insurant, code_insured, fetch_order_id, insurant.dms_product.id, start_date)
          )

          # new_insured = [
          #   {
          #     "last_name": "#{insured.last_name}",
          #     "first_name": "#{insured.first_name}",
          #     "second_name": "#{insured.second_name}",
          #     "bithday": "#{insured.birthday}",
          #     "passport": "#{insured.passport}",
          #     "division_code": "#{insured.division_code}",
          #     "division_issuing": "#{insured.division_issuing}",
          #     "date_release": "#{insured.date_release}",
          #     "birth_place": "#{insured.birth_place}",
          #     "phone": "#{insured.phone}",
          #     "email": "#{insured.email}",
          #     "registration_address": "#{insured.registration_address}",
          #     "residence": "#{insured.residence}"
          #   }
          # ]
        else
          finish_with_bot(bot, message)
            break
        end
      end
    end
  end
end
