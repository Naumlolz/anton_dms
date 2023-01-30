class PaymentLinkController < ApplicationController
  def fetch_payment_link(param_insurant, param_insured, order_id, product_id, start_date)
    url = URI('https://dev.api.etnamed.ru/v1/graphql')

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = "{\"query\":\"mutation DMSCreateOrder {\\n  dmsCreateOrder(arg: {back_url: \\\"https://dms.etnamed.ru\\\", insurant: \\\"#{param_insurant}\\\", insured: \\\"#{param_insured}\\\", order_id: \\\"#{order_id}\\\", product_id: #{product_id}, promo_code: \\\"\\\", start_date: \\\"#{start_date}\\\", payment_method: \\\"bank_card\\\", form_guid: \\\"\\\", offer_guid: \\\"\\\"}) {\\n    error\\n    ok\\n    order_id\\n    payment_link\\n    __typename\\n  }\\n}\\n\",\"variables\":{}}"

    response = https.request(request)
    res = JSON.parse(response.read_body)
    res['data']['dmsCreateOrder']['payment_link']
  end
end
