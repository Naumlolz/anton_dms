# == Schema Information
#
# Table name: dms_products
#
#  id                :bigint           not null, primary key
#  file_program_path :string
#  medical_sum       :jsonb
#  name              :string
#  price             :jsonb
#  program           :jsonb
#  uid               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  city_id           :bigint
#  product_id        :integer
#
# Indexes
#
#  index_dms_products_on_city_id  (city_id)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#
require 'rails_helper'

RSpec.describe DmsProduct, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
