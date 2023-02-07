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
  validates :phone, :gender,  :division_code, :division_issuing, presence: true

  validates :first_name, presence: true, length: {
    maximum: 50
  }
  validates :last_name, presence: true, length: {
    maximum: 50
  }
  validates :second_name, presence: true, length: {
    maximum: 50
  }
  validates :birth_place, presence: true, length: {
    maximum: 250
  }
  validates :registration_address, presence: true, length: {
    maximum: 250
  }
  validates :residence, presence: true, length: { maximum: 250 }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true
  # validates :date_release, date: { after: :birthday }, presence: true
  # validates :birthday, date: { before: :date_release }, presence: true
  validates :passport, length: { is: 10 }, presence: true

  belongs_to :dms_product

end
