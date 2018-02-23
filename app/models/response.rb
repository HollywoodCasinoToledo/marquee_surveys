class Response < ActiveRecord::Base

	belongs_to :answer
	belongs_to :patron

	def self.created_after(date)
		where('DATE(created_at) >= ?', date)
	end

	def self.created_before(date)
		date = date.blank? ? Time.now.to_date : date
		where('DATE(created_at) <= ?', date)
	end

	def group_by_date
	  created_at.to_date.to_s(:db)
	end
end
