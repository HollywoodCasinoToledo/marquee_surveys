class QuestionsController < ApplicationController

	layout 'application_admin'

	def create
		## survey = Survey.find(params[:question][:survey_id])
		style = params[:question][:style].to_s
		question = Question.new(question_params)
		question.multiple = params[:question][:multiple] if params[:question][:style] == Question::STYLE_LIST || params[:question][:style] == Question::STYLE_GRID
		previous_question = Question.find_by(survey_id: 1, next_id: nil)
		if question.save
			previous_question.update_attribute(:next_id, question.id) if !previous_question.nil?
			if style == Question::STYLE_BOOL
				Answer.create(title: "Yes", question_id: question.id).save
				Answer.create(title: "No", question_id: question.id).save
			elsif style == Question::STYLE_RATE_3
				Answer.create(title: "Exceptional", value: 3, question_id: question.id).save
				Answer.create(title: "Good", value: 2, question_id: question.id).save
				Answer.create(title: "Needs Improvement", value: 1, question_id: question.id).save
			elsif style == Question::STYLE_RATE_5
				Answer.create(title: "Exceptional", value: 5, question_id: question.id).save
				Answer.create(title: "Good", value: 4, question_id: question.id).save
				Answer.create(title: "Fair", value: 3, question_id: question.id).save
				Answer.create(title: "Poor", value: 2, question_id: question.id).save
				Answer.create(title: "Very Poor", value: 1, question_id: question.id).save
			end
		end
		flash[:title] = "Success"
		flash[:notice] = "Now add answers to the question"
		redirect_to controller: :admin, action: :edit_survey
	end

	def edit
		include_navigation_pane_variables
		
		@question = Question.find(params[:id])
		
		@categories = Hash.new
		Category.where(property_id: 25).to_a.each { |c| @categories[c.name] = c.id }

		@questions = Question.get_all_in_order.in_same_category(@question)
		@reorder_hash = Hash.new
		@reorder_hash.default = []
		@questions.joins(:category).where(survey_id: 1).each do |q|
			c = Category.find(q.category_id)
			if @reorder_hash.include? c.name
				@reorder_hash[c.name].push [q.title, q.id.to_s]
			else
				@reorder_hash[c.name] = [[q.title, q.id.to_s]]
			end
		end

		@parent_hash = Hash.new
		@parent_hash.default = []
		Answer.joins(:question).where('questions.survey_id = ?', 1).each do |a|
			q = Question.find(a.question_id)
			if @parent_hash.include? q.title
				@parent_hash[q.title].push [a.title, a.id.to_s]
			else
				@parent_hash[q.title] = [[a.title, a.id.to_s]]
			end
		end

	end

	def new
		include_navigation_pane_variables

		@categories = Hash.new
		Category.where(property_id: 25).to_a.each { |c| @categories[c.name] = c.id }
		@parent_hash = Hash.new
		@parent_hash.default = []
		Answer.joins(:question).where('questions.survey_id = ?', 1).each do |a|
			q = Question.find(a.question_id)
			if @parent_hash.include? q.title
				@parent_hash[q.title].push [a.title, a.id.to_s]
			else
				@parent_hash[q.title] = [[a.title, a.id.to_s]]
			end
		end
	end

	def update
		question = Question.find(params[:id])
		question.update_attributes(question_params)
		flash[:title] = "Success"
		flash[:notice] = "Now add answers to the question"
		redirect_to controller: :admin, action: :edit_survey
	end

	private 
		def question_params
			params.require(:question).permit(:survey_id, :title, :style, :required, :parent, :category_id)
		end

end
