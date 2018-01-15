class Question < ActiveRecord::Base

	belongs_to :category
	has_many :answers

	STYLE_LIST = "LIST"
	STYLE_GRID = "GRID"
	STYLE_RATE_3 = "RAT3"
	STYLE_RATE_5 = "RAT5"
	STYLE_BOOL = "BOOL"
	STYLE_CMNT = "CMNT"

	def self.get_all_in_order
		questions = Question.where(survey_id: 1).to_a.map!{ |q| [q.id, q.next_id] }
		orderized = Array.new
		questions_hashed = questions.to_h.invert
		current = questions_hashed[nil]
		orderized.push(current)
		begin
			current = questions_hashed[current]
			orderized.push(current)
		end until questions_hashed[current].nil?
		Question.where(id: orderized)
	end

	scope :in_same_category, -> (question) { where(category_id: question.category_id) if !question.category_id.nil? }

end
