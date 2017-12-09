class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
    	t.references	:question, null: false
    	t.string			:title, null: false
    	t.string		 	:picture, null: true
      t.timestamps null: false
    end
  end
end
