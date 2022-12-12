# == Schema Information
#
# Table name: programs
#
#  id          :bigint           not null, primary key
#  description :string
#  price       :integer
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Program < ApplicationRecord
  has_many :users
end
