class AddValueToAnswers < ActiveRecord::Migration
  def change
  	add_column :answers, :value, :integer, null: true, default: nil
  end
end
