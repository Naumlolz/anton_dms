class CreateInsurants < ActiveRecord::Migration[6.1]
  def change
    create_table :insurants do |t|
      t.integer :telegram_id
      t.string :step
      t.string :first_name
      t.string :last_name
      t.string :second_name
      t.string :gender
      t.date :birthday
      t.string :phone
      t.string :email
      t.string :birth_place
      t.string :passport
      t.date :date_release
      t.string :division_code
      t.string :division_issuing
      t.string :registration_address
      t.string :residence
      t.belongs_to :dms_product, foreign_key: true
      t.timestamps
    end
  end
end
