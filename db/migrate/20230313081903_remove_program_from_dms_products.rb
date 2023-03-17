class RemoveProgramFromDmsProducts < ActiveRecord::Migration[6.1]
  def change
    remove_column :dms_products, :program
  end
end
