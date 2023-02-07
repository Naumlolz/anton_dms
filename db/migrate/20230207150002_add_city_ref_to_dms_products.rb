class AddCityRefToDmsProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :dms_products, :city, foreign_key: true
  end
end
