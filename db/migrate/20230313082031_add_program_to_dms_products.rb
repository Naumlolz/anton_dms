class AddProgramToDmsProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :dms_products, :program, :jsonb
  end
end
