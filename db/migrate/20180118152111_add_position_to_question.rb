class AddPositionToQuestion < ActiveRecord::Migration
  def change
  	add_column	:questions, :position, :integer, auto_increment: true
  end
end
