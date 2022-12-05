class CreatePrograms < ActiveRecord::Migration[6.1]
  def change
    create_table :programs do |t|
      t.string :title
      t.string :description
      t.integer :price
      t.timestamps
    end
  end
end
