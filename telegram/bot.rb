require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require 'uri'
require 'json'
require 'net/http'
require 'date'

token = '5982315763:AAFJcUzIQN7ufbw2VgyOEfwkez67aIJ8lak'

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
        chat_id: message.chat.id,
        text: "Bye, #{message.from.username}!",
        reply_markup: kb
      )
    end

    case message.text
    when '/start'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Добровольное медицинское страхование.\nДМС - правильный выбор для тех, кто ценит своё время сервис и качество.\nЕсли Вам потребуется медицинская помощь, Вы сможете попасть к врачу в удобное время, быстро сдать анализы и пройти лечение"
      )
      KeyboardController.new.dms_products_keyboard(bot, message)
    when '/end'
      finish_with_bot(bot, message)
    when message.text
      if message.text.start_with?('Мой ДМС')
        program_name = message.text
        user.update(dms_product_id: DmsProduct.find_by(name: message.text).id)
        current_dms_product = user.dms_product
        KeyboardController.new.dms_product_options_keyboard(bot, message)
      end
      bot.listen do |message|
        case message.text
        when 'Назад'
          KeyboardController.new.dms_products_keyboard(bot, message)
          break
        when 'Прочесть описание'
          current_dms_product_titles = current_dms_product.program.map { |program| program['title'].to_s }
          current_dms_product_titles.push('Назад')
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
            keyboard: current_dms_product_titles,
            one_time_keyboard: true
          )
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Услуги:',
            reply_markup: markup
          )
          bot.listen do |hint|
            case hint.text
            when 'Назад'
              KeyboardController.new.dms_product_options_keyboard(bot, message)
              break
            end
            if current_dms_product_titles.include?(hint.text)
              current_dms_product.program.each do |program|
                if program['title'] == hint.text
                  program['description'].each do |program_item|
                    bot.api.send_message(
                      chat_id: hint.chat.id,
                      text: program_item['items']
                    )
                  end
                end
              end
            end
          end
        when 'Выбрать программу'
          insured.update(dms_product_id: DmsProduct.find_by(name: program_name).id)
          insurant.update(dms_product_id: DmsProduct.find_by(name: program_name).id)
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Вы выбрали программу: #{program_name}.\nВведите контакты страхователя\n(Тот, кто оплачивает полис)"
          )

          ProfilesController.new.user_profile_filling(insurant, bot, message)

          each_variant = %w[Да Нет].map { |variant| variant }
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
            keyboard: each_variant,
            one_time_keyboard: true
          )
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Введите контакты застрахованного\n(Тот, кто получает полис):\nСовпадает со страхователем?",
            reply_markup: markup
          )
          bot.listen do |message|
            case message.text
            when 'Да'
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
            when 'Нет'
              bot.api.send_message(
                chat_id: message.chat.id,
                text: "Введите контакты застрахованного\n(Тот, кто получает полис):"
              )
              ProfilesController.new.user_profile_filling(insured, bot, message)
              break
            end
          end

          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Страхователь:\n#{ProfilesController.new.fetch_info(insurant)}"
          )

          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Застрахованный:\n#{ProfilesController.new.fetch_info(insured)}"
          )

          insureds = []
          insureds.push(insured)

          KeyboardController.new.final_submit_keyboard(bot, message)

          bot.listen do |message|
            case message.text
            when 'Добавить застрахованное лицо'
              new_insured = Insured.create(telegram_id: message.from.id, dms_product_id: insurant.dms_product_id)
              ProfilesController.new.user_profile_filling(new_insured, bot, message)
              insureds.push(new_insured)
              KeyboardController.new.final_submit_keyboard(bot, message)
            when 'Перейти к оплате'
              break
            end
          end

          new_insureds = []

          new_insurant = {
            "last_name": insurant.last_name.to_s,
            "first_name": insurant.first_name.to_s,
            "second_name": insurant.second_name.to_s,
            "bithday": insurant.birthday.to_s,
            "passport": insurant.passport.to_s,
            "division_code": insurant.division_code.to_s,
            "division_issuing": insurant.division_issuing.to_s,
            "date_release": insurant.date_release.to_s,
            "gender": insurant.gender.to_s,
            "birth_place": insurant.birth_place.to_s,
            "phone": insurant.phone.to_s,
            "email": insurant.email.to_s,
            "registration_address": insurant.registration_address.to_s,
            "residence": insurant.residence.to_s
          }

          insureds.each do |new_insured|
            new_insureds.push(
              {
                "last_name": new_insured.last_name.to_s,
                "first_name": new_insured.first_name.to_s,
                "second_name": new_insured.second_name.to_s,
                "bithday": new_insured.birthday.to_s,
                "passport": new_insured.passport.to_s,
                "division_code": new_insured.division_code.to_s,
                "division_issuing": new_insured.division_issuing.to_s,
                "gender": new_insured.gender.to_s,
                "date_release": new_insured.date_release.to_s,
                "birth_place": new_insured.birth_place.to_s,
                "phone": new_insured.phone.to_s,
                "email": new_insured.email.to_s,
                "registration_address": new_insured.registration_address.to_s,
                "residence": new_insured.residence.to_s
              }
            )
          end

          fetch_order_id = OrderController.new.fetch_order_id
          code_insurant = Base64.strict_encode64(JSON.pretty_generate(new_insurant))
          code_insured = Base64.strict_encode64(JSON.pretty_generate(new_insureds))
          start_date = Date.today + 1.weeks

          bot.api.send_message(
            chat_id: message.chat.id,
            text: PaymentLinkController.new.fetch_payment_link(code_insurant,
                                                              code_insured,
                                                              fetch_order_id,
                                                              insurant.dms_product.id,
                                                              start_date)
          )
        else
          finish_with_bot(bot, message)
          break
        end
      end
    end
  end
end
