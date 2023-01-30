class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :telegram_id, :limit => 8
      t.string :step
      t.string :first_name
      t.string :last_name
      t.string :father_name
      t.string :gender
      t.date :date_of_birth
      t.string :phone
      t.string :email
      t.belongs_to :dms_product, foreign_key: true
      t.timestamps
    end
  end
end
