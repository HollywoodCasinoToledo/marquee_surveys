class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
    	t.references	:property, null: false
    	t.integer			:IDnum, null: false
    	t.integer			:password_digest, null: false
      t.timestamps null: false
    end
  end
end
