# == Schema Information
#
# Table name: policy_holders
#
#  id                        :bigint           not null, primary key
#  actual_residence          :string
#  date_of_birth             :date
#  division_code             :string
#  email                     :string
#  father_name               :string
#  first_name                :string
#  gender                    :string
#  issued                    :date
#  issued_by                 :string
#  last_name                 :string
#  name                      :string
#  phone                     :string
#  place_of_birth            :string
#  registration_address      :string
#  serial_number_of_passport :string
#  step                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  dms_product_id            :bigint
#  telegram_id               :integer
#
# Indexes
#
#  index_policy_holders_on_dms_product_id  (dms_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (dms_product_id => dms_products.id)
#
class PolicyHolder < ApplicationRecord
end
