class CreatePolicyHolders < ActiveRecord::Migration[6.1]
  def change
    create_table :policy_holders do |t|
      t.string :name
      t.integer :telegram_id
      t.string :step
      t.string :first_name
      t.string :last_name
      t.string :father_name
      t.string :gender
      t.date :date_of_birth
      t.string :phone
      t.string :email
      t.string :place_of_birth
      t.string :serial_number_of_passport
      t.date :issued
      t.string :division_code
      t.string :issued_by
      t.string :registration_address
      t.string :actual_residence
      t.belongs_to :dms_product, foreign_key: true
      t.timestamps
    end
  end
end
