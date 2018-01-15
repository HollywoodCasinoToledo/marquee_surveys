class QuestionPositionsToNodes < ActiveRecord::Migration
  def change
  	remove_column :questions, :position, :integer
  	add_reference :questions, :next, null: true
  end
end
