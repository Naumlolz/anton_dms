# == Schema Information
#
# Table name: users
#
#  id             :bigint           not null, primary key
#  city           :string
#  date_of_birth  :date
#  email          :string
#  father_name    :string
#  first_name     :string
#  gender         :string
#  last_name      :string
#  name           :string
#  phone          :string
#  step           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  dms_product_id :bigint
#  telegram_id    :bigint
#
# Indexes
#
#  index_users_on_dms_product_id  (dms_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (dms_product_id => dms_products.id)
#
class User < ApplicationRecord
  belongs_to :dms_product, optional: true
end
