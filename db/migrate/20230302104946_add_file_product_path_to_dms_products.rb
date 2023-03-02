class AddFileProductPathToDmsProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :dms_products, :file_program_path, :string
  end
end
