# == Schema Information
#
# Table name: insurants
#
#  id                   :bigint           not null, primary key
#  birth_place          :string
#  birthday             :date
#  date_release         :date
#  division_code        :string
#  division_issuing     :string
#  email                :string
#  first_name           :string
#  gender               :string
#  last_name            :string
#  passport             :string
#  phone                :string
#  registration_address :string
#  residence            :string
#  second_name          :string
#  step                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  dms_product_id       :bigint
#  telegram_id          :bigint
#
# Indexes
#
#  index_insurants_on_dms_product_id  (dms_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (dms_product_id => dms_products.id)
#
class Insurant < ApplicationRecord
  validates :first_name, :last_name, :second_name, :phone, :email, presence: true
  validates :gender, :birthday, :birth_place, :passport, :date_release, presence: true
  validates :division_code, :division_issuing, :registration_address, presence: true
  validates :residence, presence: true

  belongs_to :dms_product
end
