class AddPriceToDmsProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :dms_products, :price, :jsonb
  end
end
