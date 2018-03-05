class AddInstanceToResponses < ActiveRecord::Migration
  def change
  	add_column :responses, :instance_id, :string
  	add_column :comments, :instance_id, :string
  end
end
