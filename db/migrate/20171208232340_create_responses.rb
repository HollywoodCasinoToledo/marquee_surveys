class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
    	t.references	:patron, null: true
    	t.references	:question, null: true
    	t.references	:answer, null: false
      t.timestamps null: false
    end
  end
end
