class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :telegram_id
      t.string :step
      t.belongs_to :program, foreign_key: true
      t.timestamps
    end
  end
end
