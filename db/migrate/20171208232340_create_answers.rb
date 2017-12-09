class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
    	t.references	:patron, null: true
    	t.references	:question, null: true
    	t.references	:option, null: false
      t.timestamps null: false
    end
  end
end
