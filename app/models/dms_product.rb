# == Schema Information
#
# Table name: dms_products
#
#  id          :bigint           not null, primary key
#  medical_sum :jsonb
#  name        :string
#  price       :jsonb            is an Array
#  program     :jsonb            is an Array
#  uid         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class DmsProduct < ApplicationRecord
end
