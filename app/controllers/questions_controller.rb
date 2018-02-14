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
		@display_ordered_array = Array.new
		@question = Question.find(params[:id])
		@questions = Question.all.map(&:category_id).map! { |x| x.nil? ? 0 : x }.chunk{|n| n}.map(&:first)
		uncategorized_questions = Question.where(active: true, category_id: nil).map(&:title)
		@questions.each do |x| 
			if x == 0
				@display_ordered_array.push(uncategorized_questions.shift)
			else
				@display_ordered_array.push({Category.find(x).name => Question.where(category_id: x).map(&:title)})
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
		@selected_answers = Response.where(instance_id: session[:instance_id]).map(&:answer_id)

		# Create array of starting display questions for backwards navigation.
		# Get questions that will be able to be grouped AND can depend on parent questions within the group. This will add the depending
		# child question to the top of the group and will display if the correct parent is selected.
		@starting_positions1 = Question.select('min(position) as pos').group(:category_id).order(:position).map(&:pos)
		@starting_positions2 = Question.where(style: [Question::STYLE_RATE_3, Question::STYLE_RATE_5, Question::STYLE_BOOL]).select('min(position) as pos').group(:category_id).order(:position).map(&:pos)
		@display_order = Question.where(position: [@starting_positions1, @starting_positions2]).map(&:id)
		@styles = Question.where.not(category_id: nil, parent: nil).where(style: [Question::STYLE_RATE_3, Question::STYLE_RATE_5, Question::STYLE_BOOL]).order(:position).map(&:id)
		
		# Merge together and order the array of question display starter IDs
		@starters = @display_order.push(@styles).flatten
		@display_order = Question.order(:position).find(@starters).map(&:id)

		# Get the question previous to the quesiton in the array for the back button
		this_index = @display_order.index(@question.id)

		if !@question.can_be_displayed(@selected_answers) && this_index < @display_order.count
			if params[:direction] == "Back"
				redirect_to controller: :questions, action: :show, id: Question.find(@display_order.fetch(this_index - 1) )
			else
				redirect_to controller: :questions, action: :show, id: Question.find(@display_order.fetch(this_index + 1) )
			end
		end

		@previous_question_id = @display_order.fetch(this_index - 1)
		if this_index < @display_order.count - 1
			@next_question_id = @display_order.fetch(this_index + 1) 
		end

		if @question.position == 1
	    loop do
	      session[:instance_id] = SecureRandom.hex.slice(0..12)
	      break unless Response.find_by(instance_id: session[:instance_id])
	    end
	  end

	  
	  @question = @question.get_next_question(@selected_answers) if !@question.can_be_displayed(@selected_answers)
		@questions = Question.where(active: true).order(:position)

		if @question.category_id.nil?
			@answers = Answer.where(question_id: @question.id)
		else
			@category = Category.find(@question.category_id) 
			groupable = Array.new
			if this_index + 1 < @display_order.count
				next_display_order_position = Question.find(@display_order.fetch(this_index + 1)).position
			else
				next_display_order_position = @questions.last.position + 1
			end
			@questions.where(category_id: @category.id).where("position >= ? AND position < ?", @question.position, next_display_order_position).each { |q| q.is_groupable(@selected_answers) ? groupable.push(q.id) : break }
			@question_group = @questions.find(groupable)
		end
		
		@first_question = Question.find_by(active: true, position: 1) if @next_question.nil?
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
			params.require(:question).permit(:survey_id, :title, :style, :required, :category_id, :multiple)
		end

	def decide_layout
		['new', 'edit', 'move', 'parent'].include?(action_name) ? 'application_admin' : 'application_main'
	end

end
