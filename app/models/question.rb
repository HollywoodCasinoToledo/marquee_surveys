class Question < ActiveRecord::Base

	belongs_to :category
	has_many :answers

	STYLE_LIST = "LIST"
	STYLE_GRID = "GRID"
	STYLE_RATE_3 = "RAT3"
	STYLE_RATE_5 = "RAT5"
	STYLE_BOOL = "BOOL"
	STYLE_CMNT = "CMNT"

	def autogenerate_answers
		if self.style == STYLE_BOOL
			Answer.create(title: "Yes", question_id: self.id).save
			Answer.create(title: "No", question_id: self.id).save
		elsif self.style == STYLE_RATE_3
			Answer.create(title: "Exceptional", value: 3, question_id: self.id).save
			Answer.create(title: "Good", value: 2, question_id: self.id).save
			Answer.create(title: "Needs Improvement", value: 1, question_id: self.id).save
		elsif self.style == STYLE_RATE_5
			Answer.create(title: "Exceptional", value: 5, question_id: self.id).save
			Answer.create(title: "Good", value: 4, question_id: self.id).save
			Answer.create(title: "Fair", value: 3, question_id: self.id).save
			Answer.create(title: "Poor", value: 2, question_id: self.id).save
			Answer.create(title: "Very Poor", value: 1, question_id: self.id).save
		end
	end

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
		orderized.reverse!
		Question.find(orderized).index_by(&:id).slice(*orderized).values
	end

	def get_possible_parents
		@selection_hash = Hash.new
		@selection_hash.default = []
		questions = Question.get_all_in_order.to_a.map(&:id).split(self.id)[0]
		Question.where(id: questions).each_with_index do |q, i|
			pos = (i.to_i + 1).to_s + ". "
			a = Answer.where(question_id: q.id).each do |a|
				if @selection_hash.include? pos + q.title
					@selection_hash[pos + q.title].push [a.title, a.id.to_s]
				else
					@selection_hash[pos + q.title] = [[a.title, a.id.to_s]]
				end
			end
		end
		return @selection_hash
	end

	def has_parent_answers?
		answer_ids = Answer.where(question_id: self.id).map(&:id)
		!Question.where(parent: answer_ids).blank? || !Category.where(parent: answer_ids).blank?
	end

	def reorder_before(question_id)
		after_question = Question.find(question_id)
		before_question = Question.find_by(next_id: question_id)
		if after_question.category_id == before_question.category_id && self.category_id != after_question.category_id
			raise Exceptions::QuestionOrderError.new("Question must first be put into corresponding category."), Category.find(after_question.category_id).name 
		else
			Question.find_by(next_id: self.id).update_attribute(:next_id, nil)
			before_question.update_attribute(:next_id, self.id)
			self.update_attribute(:next_id, after_question.id)

		end
	end

	scope :in_same_category, -> (question) { where(category_id: question.category_id) if !question.category_id.nil? }

end
