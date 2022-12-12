# == Schema Information
#
# Table name: users
#
#  id          :bigint           not null, primary key
#  name        :string
#  step        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  program_id  :bigint
#  telegram_id :integer
#
# Indexes
#
#  index_users_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#
require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
