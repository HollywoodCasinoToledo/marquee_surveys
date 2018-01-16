class QuestionsController < ApplicationController

	layout 'application_admin'

	before_action :include_navigation_pane_variables, only: [:edit, :new]

	def create
		## survey = Survey.find(params[:question][:survey_id])
		style = params[:question][:style].to_s
		question = Question.new(question_params)
		question.multiple = params[:question][:multiple] if params[:question][:style] == Question::STYLE_LIST || params[:question][:style] == Question::STYLE_GRID
		previous_question = Question.find_by(survey_id: 1, next_id: nil)
		if question.save
			previous_question.update_attribute(:next_id, question.id) if !previous_question.nil?
			question.autogenerate_answers # Generates answers if a rate or yes/no question.
		end
		flash[:title] = "Success"
		flash[:notice] = "Now add answers to the question"
		redirect_to controller: :admin, action: :edit_survey
	end

	def edit
		@question = Question.find(params[:id])
		@categories = Hash.new
		Category.where(property_id: 25).to_a.each { |c| @categories[c.name] = c.id }
		@questions = Question.get_all_in_order.to_a.map!.with_index { |q, i| [(i.to_i + 1).to_s + ". " + q.title, q.id] }
		@parent_hash = @question.get_possible_parents
	end

	def new
		@categories = Hash.new
		Category.where(property_id: 25).to_a.each { |c| @categories[c.name] = c.id }
		@parent_hash = Answer.get_parent_answers_hash(1)
	end

	def update
		question = Question.find(params[:id])
		question.update_attributes(question_params)
		begin
			question.reorder_before(params[:question][:next_id])
		rescue Exceptions::QuestionOrderError => error
			flash[:title] = "Error"
			flash[:notice] = error.message
		end
		
		redirect_to controller: :admin, action: :edit_survey
	end

	private 
		def question_params
			params.require(:question).permit(:survey_id, :title, :style, :required, :parent, :category_id)
		end

end
