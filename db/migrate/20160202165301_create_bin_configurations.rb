class CreateBinConfigurations < ActiveRecord::Migration
  def change
    create_table :bin_configurations do |t|

      t.timestamps
    end
  end
end
