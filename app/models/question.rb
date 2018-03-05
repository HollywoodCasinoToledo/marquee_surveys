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
		if self.category_id.nil? || Question.all.nil?
			if self.position.nil?
				self.place_at_end_of_survey
			else
				self.move_to_end_of_survey
			end
		else
			self.place_at_end_of_category
		end
	end

	def has_parent_answers?
		answer_ids = Answer.where(question_id: self.id).map(&:id)
		!Question.where(parent: answer_ids).blank? || !Category.where(parent: answer_ids).blank?
	end

	def has_parent_order_conflicts?(question)
		conflicts = false
		if !self.parent.nil?
			parent = Answer.find(self.parent)
			parent_question = Question.find(parent.question_id)
			conflicts = parent_question.position > question.position
		else
			answers = Answer.where(question_id: self.id).map(&:id)
			children = Question.where(parent: answers)
			if !children.blank?
				children.map(&:position).each do |p|
					conflicts = true if p >= question.position
				end
			end
		end
		conflicts
	end

	def reorder_before(question)
		if !self.has_parent_order_conflicts?(question)
			old_pos = self.position
			new_pos = question.position
			if old_pos < new_pos
				Question.where('position < ? AND position > ?', new_pos, old_pos).update_all("position = position - 1")
				self.update_attribute(:position, new_pos - 1)
			else
			 	Question.where('position >= ? AND position < ?', new_pos, old_pos).update_all("position = position + 1")
			 	self.update_attribute(:position, new_pos)
			end
		else
			raise Exceptions::QuestionOrderError.new("Cannot move a question above it's own parent.")
		end
	end

	def place_at_end_of_category
		last_question = Question.where.not(id: self.id).where(category_id: self.category_id, active: true).order(:position).last
		if !last_question.nil? && !last_question.position.nil?
			below_question = Question.find_by(position: last_question.position + 1)
			if below_question.nil?
				if self.position.nil?
					self.place_at_end_of_survey 
				else
					self.move_to_end_of_survey
				end
			else
				self.place_at_end_of_survey
				self.reorder_before(below_question)
			end
		else
			self.place_at_end_of_survey
		end
	end

	def place_at_end_of_survey
		last_question = Question.where(survey_id: 1, active: true).order(:position).last
		if !last_question.nil? && !last_question.position.nil?
			self.update_attribute(:position, last_question.position + 1)
		else
			self.update_attribute(:position, 1)
		end
	end

	def move_to_end_of_survey
		old_pos = self.position
		last_question = Question.where(survey_id: 1, active: true).order(:position).last
		if !last_question.nil? && !last_question.position.nil?
			Question.where('position <= ? AND position > ?', last_question.position, old_pos).update_all("position = position - 1")
			self.update_attribute(:position, last_question.position)
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

	def get_group

	end

	def can_calculate_rating
		self.style == Question::STYLE_RATE_3 || self.style == Question::STYLE_RATE_5 || self.style == Question::STYLE_BOOL
	end

	def can_be_displayed(selected)
		self.parent.nil? || selected.include?(self.parent)
	end

	def is_groupable(selected)
		self.is_groupable_style && self.is_groupable_based_on_parent(selected)
	end

	def is_groupable_style
		self.style == Question::STYLE_RATE_3 || self.style == Question::STYLE_RATE_5 || self.style == Question::STYLE_BOOL
	end

	def is_groupable_based_on_parent(selected)
		self.parent.nil? || selected.include?(self.parent)
	end

	def get_first_in_display_group
		groupable = Array.new
		Question.where(category_id: self.category_id).where("position <= ?", self.position).order(position: :desc).map { |q| q.is_groupable ? groupable.push(q.id) : break }
		groupable.pop
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

	def get_next_question(selected)
		if Question.find_by(active: true, position: self.position + 1).nil?
			return nil
		else
			q = self
	  	loop do
	      q = Question.find_by(active: true, position: q.position + 1)
	      break unless !q.can_be_displayed(selected)
	    end
			return q
		end
	end

	def get_previous_question_id(selected)
		question = Question.find_by(position: self.position - 1)

	  if !question.category_id.nil?
	  	groupable = Array.new
	  	groupable.push(question.id) if question.is_groupable(selected)
	  	Question.where(active: true).where(category_id: question.category_id).where("position <= ?", question.position).order(position: :desc).each { |q| q.is_groupable(selected) ? groupable.push(q.id) : break }
	  	return groupable.last
	  else
	  	question.id
	  end
	end

end
