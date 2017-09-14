class AddPushedAtToPackage < ActiveRecord::Migration[5.1]
  def change
    add_column :packages, :pushed_at, :datetime
  end
end
