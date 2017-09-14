class CreateTables < ActiveRecord::Migration[5.0]
  def change
    create_table :packages do |t|
      t.string :repository

      t.timestamps null: false
    end

    create_table :versions do |t|
      t.references :package, index: true, foreign_key: true
      t.string :version
      t.json :package_json
      t.json :documentation
      t.text :readme

      t.timestamps
    end
  end
end
