class ProfilesController < ApplicationController
  def user_profile_filling(user_profile, bot, message)
    user_profile.update(step: 'last name')
    bot.api.send_message(
      chat_id: message.chat.id,
      text: 'Введите фамилию:'
    )
    bot.listen do |message|
      case user_profile.step
      when 'last name'
        if message.text.match?(/[0-9]/) || message.text.size >= 50
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите корректную фамилию:'
          )
        else
          user_profile.last_name = message.text
          user_profile.update(step: 'first name')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите имя:'
          )
        end
      when 'first name'
        if message.text.match?(/[0-9]/) || message.text.size >= 50
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите корректное имя:'
          )
        else
          user_profile.first_name = message.text
          user_profile.update(step: 'second name')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите отчество:'
          )
        end
      when 'second name'
        if message.text.match?(/[0-9]/) || message.text.size >= 50
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите корректное отчество:'
          )
        else
          user_profile.second_name = message.text
          user_profile.update(step: 'gender')
          genders = %w[Мужской Женский]
          each_gender = genders.map { |gender| gender }
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
            keyboard: each_gender,
            one_time_keyboard: true
          )
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Выберите пол:',
            reply_markup: markup
          )
        end
      when 'gender'
        user_profile.gender = message.text
        user_profile.update(step: 'birthday')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Введите дату рождения:'
        )
      when 'birthday'
        user_profile.birthday = message.text
        if user_profile.birthday.nil?
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите корректную дату рождения'
          )
        elsif !message.text.split('.').reverse.join('-').between?((Date.today - 100.years).to_s, (Date.today - 18.years).to_s)
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Лицо должно быть не моложе 18 лет'
          )
        else
          user_profile.update(step: 'phone_number')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите номер телефона:'
          )
        end
      when 'phone_number'
        if !message.text.match?(/(^8|7|\+7)((\d{10})|(\s\(\d{3}\)\s\d{3}\s\d{2}\s\d{2}))/)
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Укажите корректный номер телефона:\nНапример '89991231231'"
          )
        else
          user_profile.phone = message.text
          user_profile.update(step: 'email')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите эл. почту:'
          )
        end
      when 'email'
        if !message.text.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Укажите корректный адрес эл. почты:\nНапример 'example@gmail.com'"
          )
        else
          user_profile.email = message.text
          user_profile.update(step: 'birth_place')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Паспортные данные страхователя\nВведите место рождения:"
          )
        end
      when 'birth_place'
        if message.text.size >= 250
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Недопустимая длина строки'
          )
        else
          user_profile.birth_place = message.text
          user_profile.update(step: 'passport')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите серию и номер паспорта:'
          )
        end
      when 'passport'
        if message.text.match?(/[А-Яа-яa-zA-Z]/) || message.text.size != 10
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите корректные паспортные данные:'
          )
        else
          user_profile.passport = message.text
          user_profile.update(step: 'date_release')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Когда выдан:'
          )
        end
      when 'date_release'
        user_profile.date_release = message.text
        if user_profile.date_release.nil? || message.text.split('.').reverse.join('-') > Date.today.to_s
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Введите корректную дату выдачи паспорта'
          )
        else
          user_profile.update(step: 'division_code')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Код подразделения:'
          )
        end
      when 'division_code'
        user_profile.division_code = message.text
        user_profile.update(step: 'division_issuing')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Кем выдан:'
        )
      when 'division_issuing'
        user_profile.division_issuing = message.text
        user_profile.update(step: 'registration_address')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Адрес регистрации:'
        )
      when 'registration_address'
        if message.text.size >= 250
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Недопустимая длина строки'
          )
        else
          user_profile.registration_address = message.text
          user_profile.update(step: 'residence')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Адрес фактического места жительства:'
          )
        end
      when 'residence'
        if message.text.size >= 250
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Недопустимая длина строки'
          )
        else
          user_profile.residence = message.text
          user_profile.update(step: 'submitted') and return
        end
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
end
