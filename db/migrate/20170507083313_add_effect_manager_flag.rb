class AddEffectManagerFlag < ActiveRecord::Migration[5.1]
  def change
  	add_column :versions, :effect_manager, :boolean
  end
end
