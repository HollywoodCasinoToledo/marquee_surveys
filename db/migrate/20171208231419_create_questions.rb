class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
    	t.references	:survey, null: false
    	t.string			:title, null: false
    	t.string			:style, limit: 4, null: true
    	t.boolean			:multiple, default: false
    	t.integer			:position, null: true
    	t.boolean			:required, default: false
    	t.integer			:parent, null: true
      t.timestamps null: false
    end
  end
end
