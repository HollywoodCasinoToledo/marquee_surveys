class AddPasswordToProperties < ActiveRecord::Migration
  def change
  	add_column :properties, :password_digest, :string, default: 'Hollywood'
  end
end
