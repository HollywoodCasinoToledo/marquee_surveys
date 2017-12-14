class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
    	t.integer		:code, null: false
    	t.string		:name, null: false
      t.timestamps null: false
    end
  end
end
