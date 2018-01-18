class Category < ActiveRecord::Base

	has_many :questions

	def find_tail
		qs = Question.where(category_id: self.id).to_a.map!{ |q| [q.id, q.next_id] }
		tail = qs[0][1]
		qs = qs.to_h
		while !qs[tail].blank?
			tail = qs[tail] 
		end
		tail
	end

	def self.find_tail_from_id(id)
		qs = Question.where(category_id: id).to_a.map!{ |q| [q.id, q.next_id] }
		tail = qs[0][1]
		qs = qs.to_h
		while !qs[tail].blank?
			tail = qs[tail] 
		end
		tail
	end

	def questions_in_order
		questions = Question.where(category_id: self).to_a.map!{ |q| [q.id, q.next_id] }
		tail = self.find_tail
		orderized = Array.new
		questions_hashed = questions.to_h.invert
		current = questions_hashed[nil]
		orderized.push(current)
		begin
			current = questions_hashed[current]
			orderized.push(current)
		end until questions_hashed[current] == tail
		orderized
	end

end
