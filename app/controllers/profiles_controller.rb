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
        user_profile.last_name = message.text
        user_profile.update(step: 'first name')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Введите имя:'
        )
      when 'first name'
        user_profile.first_name = message.text
        user_profile.update(step: 'second name')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Введите отчество:'
        )
      when 'second name'
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
      when 'gender'
        user_profile.gender = message.text
        user_profile.update(step: 'birthday')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Введите дату рождения:'
        )
      when 'birthday'
        user_profile.birthday = message.text
        user_profile.update(step: 'phone_number')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Введите номер телефона:'
        )
      when 'phone_number'
        user_profile.phone = message.text
        user_profile.update(step: 'email')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Введите эл. почту:'
        )
      when 'email'
        user_profile.email = message.text
        user_profile.update(step: 'birth_place')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Паспортные данные страхователя\nВведите место рождения:"
        )
      when 'birth_place'
        user_profile.birth_place = message.text
        user_profile.update(step: 'passport')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Введите серию и номер паспорта:'
        )
      when 'passport'
        user_profile.passport = message.text
        user_profile.update(step: 'date_release')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Когда выдан:'
        )
      when 'date_release'
        user_profile.date_release = message.text
        user_profile.update(step: 'division_code')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Код подразделения:'
        )
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
        user_profile.registration_address = message.text
        user_profile.update(step: 'residence')
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Адрес фактического места жительства:'
        )
      when 'residence'
        user_profile.residence = message.text
        user_profile.update(step: 'submitted') and return
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