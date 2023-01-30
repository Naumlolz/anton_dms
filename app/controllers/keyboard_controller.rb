class KeyboardController < ApplicationController
  def final_submit_keyboard(bot, message)
    variants = ['Добавить застрахованное лицо', 'Перейти к оплате'].map { |variant| variant }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: variants,
      one_time_keyboard: true
    )
    bot.api.send_message(
      chat_id: message.chat.id,
      text: 'Выберите действие:',
      reply_markup: markup
    )
  end

  def dms_products_keyboard(bot, message)
    dms_products = DmsProduct.all
    arr_of_dms_products = dms_products.map { |dms_product| dms_product.name.to_s }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: arr_of_dms_products,
      one_time_keyboard: true
    )
    bot.api.send_message(
      chat_id: message.chat.id,
      text: 'Программы ДМС:',
      reply_markup: markup
    )
  end

  def dms_product_options_keyboard(bot, message)
    current_dms_product_options = ['Прочесть описание', 'Выбрать программу', 'Назад']
    option_to_choose = current_dms_product_options.map { |option| option }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: option_to_choose,
      one_time_keyboard: true
    )
    bot.api.send_message(
      chat_id: message.chat.id,
      text: 'Выберите опцию:',
      reply_markup: markup
    )
  end
end
