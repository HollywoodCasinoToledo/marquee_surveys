class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
    	t.references	:patron, null: true
    	t.references	:question, null: true
    	t.text				:comment, null: true
      t.timestamps null: false
    end
  end
end
