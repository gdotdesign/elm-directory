class AddStarsToPackages < ActiveRecord::Migration[5.0]
  def change
    add_column :packages, :stars, :integer
  end
end
