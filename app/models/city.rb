# == Schema Information
#
# Table name: cities
#
#  id         :bigint           not null, primary key
#  active     :boolean
#  name       :string
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class City < ApplicationRecord
end
