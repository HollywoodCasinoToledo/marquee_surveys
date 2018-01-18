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

	def has_parent_answers?
		answer_ids = Answer.where(question_id: self.id).map(&:id)
		!Question.where(parent: answer_ids).blank? || !Category.where(parent: answer_ids).blank?
	end

	def assign_position
		if self.category_id.nil?
			self.place_at_end_of_survey
		else
			category_end = Question.where(category_id: self.category_id).order(:position).last
			if !category_end.position.nil? && !Question.find_by(position: category_end.position + 1).nil?
				# If the quesiton belongs to a category and the category has questions after the end of the category,
				# move the following questions down and insert this quesiton into a position within the category.
				question_following_category = Question.find_by(position: category_end.position + 1)
				self.move_before(question_following_category)
			else
				# Simply added to the bottom as the last question.
				self.place_at_end_of_survey
			end
		end
	end

	def move_before(question)
		pos = question.position
		Question.where('position >= ?', pos).update_all("position = position + 1")
		self.update_attribute(:position, pos)
	end

	def place_at_beginning_of_survey

	end

	def place_at_end_of_survey
		self.update_attribute(:position, Question.where(survey_id: 1).order(:position).last.position + 1)
	end

	scope :in_same_category, -> (question) { where(category_id: question.category_id) if !question.category_id.nil? }

end

Question.where(category_id: 5).order(:position).last