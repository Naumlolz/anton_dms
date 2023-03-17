class RemovePriceFromProducts < ActiveRecord::Migration[6.1]
  def change
    remove_column :dms_products, :price
  end
end
