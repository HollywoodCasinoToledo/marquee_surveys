class AddCategoryToQuestion < ActiveRecord::Migration
  def change
  	add_reference		:questions, :category, null: true
  end
end
