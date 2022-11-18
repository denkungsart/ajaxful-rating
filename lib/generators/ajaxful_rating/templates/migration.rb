class CreateRates < ActiveRecord::Migration
  def self.up
    create_table :rates do |t|
      t.belongs_to :rater, polymorphic: true
      t.belongs_to :rateable, polymorphic: true
      t.integer :stars, null: false
      t.string :dimension
      t.timestamps
    end

    add_index :rates, [:rater_id, :rater_type]
    add_index :rates, [:rateable_id, :rateable_type]
  end

  def self.down
    drop_table :rates
  end
end
