class CreateDmsProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :dms_products do |t|
      t.jsonb :medical_sum
      t.string :name
      t.jsonb :price, array: true
      t.jsonb :program, array: true
      t.string :uid
      t.timestamps
    end
  end
end
