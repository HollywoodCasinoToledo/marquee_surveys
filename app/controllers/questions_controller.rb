class QuestionsController < ApplicationController

	layout :decide_layout

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
		uncategorized_questions = Question.where(active: true, category_id: nil).map(&:title)
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
			@possible_moves = Question.where.not(id: @question.id).order(:position).where(category_id: @question.category_id).to_a.map.with_index { |q, i| [q.position.to_s + ". " + q.title, q.id] }
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

	def show
		@question = Question.find(params[:id])
		if @question.position == 1
	    loop do
	      session[:instance_id] = SecureRandom.hex.slice(0..12)
	      break unless Response.find_by(instance_id: session[:instance_id])
	    end
	  end

	  @selected_answers = Response.where(instance_id: session[:instance_id]).map(&:answer_id)

	  @question = @question.get_next_question(@selected_answers) if !@question.can_be_displayed(@selected_answers)

		@questions = Question.where(active: true).order(:position)

		if @question.category_id.nil?
			@answers = Answer.where(question_id: @question.id)
			@next_question = Question.find_by(active: true, position: @question.position + 1)
		else
			@category = Category.find(@question.category_id) 
			groupable = Array.new
			@questions.where(category_id: @category.id).where("position >= ?", @question.position).each { |q| q.is_groupable(@selected_answers) ? groupable.push(q.id) : break }
			@question_group = @questions.find(groupable)
			if @question_group.nil? || @question_group.count == 0
				@next_question = Question.find_by(active: true, position: @question.position + 1)
			else
				@next_question = Question.find_by(active: true, position: @question_group.last.position + 1)
			end
		end
		
		@first_question = Question.find_by(active: true, position: 1) if @next_question.nil?

		if @question.style == Question::STYLE_CMNT
			@route = {controller: :comments, action: :create}
		else
			@route = {controller: :responses, action: :create}
		end
		

		if !params[:order].nil?
			ary = params[:order].split(",")
			@order_array = ary
			@order_string = params[:order]
			@previous_question_id = ary.pop.to_i
			@order_back = ary.join(",")
		end
		
	end

	def update
		question = Question.find(params[:id])
		category_id = question.category_id
		begin
			case params[:question][:operation]
			when "move"
				question.reorder_before(Question.find(params[:question][:next_id]))
			when "move_to_end"
				question.move_to_end_of_survey
			when "parent"
				question.update_attribute(:parent, params[:question][:parent].blank? ? nil : params[:question][:parent])
			else
				question.update_attributes(question_params)
		end
		position = 1
		Question.where(active: true).order(:position).each do |q| 
			q.update_attribute(:position, position)
			position = position + 1
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
			params.require(:question).permit(:survey_id, :title, :style, :required, :category_id, :multiple, :active)
		end

	def decide_layout
		['new', 'edit', 'move', 'parent'].include?(action_name) ? 'application_admin' : 'application_main'
	end

end
