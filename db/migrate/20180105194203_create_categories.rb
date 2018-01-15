class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
    	t.references		:property, null: false
    	t.references		:survey, null: false
    	t.string				:name, null: false
    	t.integer				:parent, null: true
      t.timestamps null: false
    end
  end
end
