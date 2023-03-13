class AddProductIdToDmsProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :dms_products, :product_id, :integer
  end
end
