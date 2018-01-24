class QuestionsController < ApplicationController

	layout 'application_admin'

	before_action :include_navigation_pane_variables, only: [:edit, :new, :move, :parent]

	def create
		## survey = Survey.find(params[:question][:survey_id])
		style = params[:question][:style].to_s
		question = Question.new(question_params)
		question.multiple = params[:question][:multiple] if params[:question][:style] == Question::STYLE_LIST || params[:question][:style] == Question::STYLE_GRID

		if question.save
			question.autogenerate_answers
			question.assign_position
		end
		flash[:title] = "Success"
		flash[:notice] = "Question created"
		redirect_to controller: :admin, action: :edit_survey
	end

	def edit
		@question = Question.find(params[:id])
		@categories = Hash.new
		Category.where(property_id: 25).to_a.each { |c| @categories[c.name] = c.id }
		@questions = Question.order(:position).to_a.map!.with_index { |q, i| [(i.to_i + 1).to_s + ". " + q.title, q.id] }
		@parent_hash = Answer.as_select_hash(1)
	end

	def move
		@ordered_array = Array.new
		@question = Question.find(params[:id])
		@questions = Question.all.map(&:category_id).map! { |x| x.nil? ? 0 : x }.chunk{|n| n}.map(&:first)
		uncategorized_questions = Question.where(survey_id: 1, category_id: nil).map(&:title)
		@questions.each do |x| 
			if x == 0
				@ordered_array.push(uncategorized_questions.shift)
			else
				@ordered_array.push({Category.find(x).name => Question.where(category_id: x).map(&:title)})
			end
		end
		@possible_moves = Array.new
		if @question.category_id.nil?
			@possible_moves = Question.where.not(id: @question.id).group('IFNULL(category_id, id)').order(:position).to_a.map.with_index { |q, i| [q.position.to_s + ". " + q.title, q.id] }
		else
			@possible_moves = Question.where.not(id: @question.id).where(category_id: @question.category_id).to_a.map.with_index { |q, i| [q.position.to_s + ". " + q.title, q.id] }
		end
		@possible_moves.push(['Move to end', 'move_to_end']) if @question.category_id.nil?
	end

	def new
		@categories = Hash.new
		Category.where(property_id: 25).to_a.each { |c| @categories[c.name] = c.id }
		@parent_hash = Answer.as_select_hash(1)
	end

	def parent
		@question = Question.find(params[:id])
		@parent_hash = @question.get_possible_parents
	end

	def update
		question = Question.find(params[:id])
		category_id = question.category_id
		question.update_attributes(question_params)
		begin
			case params[:question][:operation]
			when "move"
				question.reorder_before(Question.find(params[:question][:next_id]))
			when "move_to_end"
				question.move_to_end_of_survey
			when "parent"
				question.update_attribute(:parent, params[:question][:parent].blank? ? nil : params[:question][:parent])
			else
				question.assign_position
			end
		flash[:title] = "Success"
		flash[:notice] = "Question updated"
		rescue Exceptions::QuestionOrderError => error
			flash[:title] = "Error"
			flash[:notice] = error.message
		end
		redirect_to controller: :questions, action: :edit, id: params[:id]
	end

	private 
		def question_params
			params.require(:question).permit(:survey_id, :title, :style, :required, :category_id)
		end

end
