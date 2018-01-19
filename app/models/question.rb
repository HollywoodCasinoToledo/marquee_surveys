class Question < ActiveRecord::Base

	belongs_to :category
	has_many :answers

	STYLE_LIST = "LIST"
	STYLE_GRID = "GRID"
	STYLE_RATE_3 = "RAT3"
	STYLE_RATE_5 = "RAT5"
	STYLE_BOOL = "BOOL"
	STYLE_CMNT = "CMNT"

	scope :in_same_category, -> (question) { where(category_id: question.category_id) if !question.category_id.nil? }

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

	def assign_position
		if self.category_id.nil? || @nav_questions.blank?
			self.place_at_end_of_survey
		else
			category_end = Question.where.not(id: self.id).where(category_id: self.category_id).order(:position).last
			if !category_end.position.nil? && !Question.find_by(position: category_end.position + 1).nil?
				# If the quesiton belongs to a category and the category has questions after the end of the category,
				# reorder the following questions down and insert this quesiton into a position within the category.
				question_following_category = Question.find_by(position: category_end.position + 1)
				self.reorder_before(question_following_category)
			else
				# Simply added to the bottom as the last question.
				self.place_at_end_of_survey
			end
		end
	end

	def has_parent_answers?
		answer_ids = Answer.where(question_id: self.id).map(&:id)
		!Question.where(parent: answer_ids).blank? || !Category.where(parent: answer_ids).blank?
	end

	def has_parent_order_conflicts?(question)
		valid = true
		parent = Question.find(self.parent_id) if !self.parent_id.nil?
		children = Question.where(parent_id: self.id).order(:position)
		valid = false if question.position <= parent.position 
		valid = false if !children.nil? && (children.last.position <= question.position)
	end

	def reorder_before(question)
		if self.valid_reorder_before(question)
			pos = question.position
			Question.where('position >= ?', pos).update_all("position = position + 1")
			self.update_attribute(:position, pos)
		else
			raise Exceptions::QuestionOrderError.new("Question must first be put into corresponding category."), Category.find(question.category_id).name 
		end
	end


	def place_at_end_of_category
		last_question = Question.where(category_id: self.category_id).order(:position).last
		if !last_question.nil? && !last_question.position.nil?
			self.update_attribute(:position, last_question.position + 1)
		else
			self.update_attribute(:position, 1)
		end
	end

	def place_at_end_of_survey
		last_question = Question.where(survey_id: 1).order(:position).last
		if !last_question.nil? && !last_question.position.nil?
			self.update_attribute(:position, last_question.position + 1)
		else
			self.update_attribute(:position, 1)
		end
	end

	def valid_reorder_before(question)
		before_question = Question.find_by(position: question.position - 1)
		if self.category_id.nil?
			# If question has no category, it cannot be placed between two quesitons that do share a category
			return false if question.category_id == before_question.category_id
		else
			# If in a category, there must be a question either above or below the new position that belongs to teh same category
			return true if self.category_id == before_question.category_id || question.category_id == self.category_id
		end
		return true
	end



	def get_possible_parents
		@selection_hash = Hash.new
		@selection_hash.default = []
		questions = Question.where(survey_id: 1).where('position < ?', self.position).to_a.map(&:id)
		Question.where(id: questions).order(:position).each_with_index do |q, i|
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



end
