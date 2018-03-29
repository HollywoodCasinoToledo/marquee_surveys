class AdminController < ApplicationController
	include AdminsHelper 

	layout :decide_layout
	before_filter :authenticate_user_is_admin, :except => [:access, :authenticate]

	# Login form for admin access
  def access

  end

  # Verify correct login credentials and create new admin session
  def authenticate
  	#property = Property.find(25)
  	#if property.authenticate(params[:password])
    if params[:password] == "Toledo123"
      session[:granted] = true
      flash[:title] = "Success"
      flash[:notice] = "Access Granted"
      redirect_to action: :edit_survey
	  else
	  	flash[:title] = "Error"
      flash[:notice] = "Access Denied"
      redirect_to action: :access
	  end
  end

	def archive
		include_navigation_pane_variables 
		@questions = Question.where(active: false)
	end

	def control_panel
		
	end

	def edit_survey
		include_navigation_pane_variables
		
		@categories = Category.where(survey_id: 1).to_a.map(&:id)
		@qs = Question.where(active: true).order(:position).to_a.map!{ |q| [q.id, q.next_id] }
		@orderized = Array.new
		data = @qs.to_h.invert
		current = data[nil]
		@orderized.push(current)
		begin
			current = data[current]
			@orderized.push(current)
		end until data[current].nil?

		@questions = Question.find(@orderized)
	end

	def results
		@question = Question.find(params[:id])
		if @question.style == Question::STYLE_CMNT
			@results = Comment.where(question_id: @question.id)
			@results = @results.where('comment LIKE ?', "%#{params[:keyword]}%") if !params[:keyword].nil?
		else
			@answers = Answer.where(question_id: @question.id)
			@results = Response.where(question_id: @question.id)
			@answer_totals = @results.group(:answer_id).count
		end
		
		if params[:onlyshow] == "Members"
			@results = @results.where.not(patron_id: nil)
		elsif params[:onlyshow] == "Anon"
			@results = @results.where(patron_id: nil)
		end
		
		if !params[:from].blank?
			@day_data = @results.created_after(params[:from]).created_before(params[:to]).group_by(&:group_by_date).map {|k,v| [k, v.length]}.sort
		end
		
	end
	
	def comments

	end

	def group_by_criteria
	  created_at.to_date.to_s(:db)
	end

	def decide_layout
		['access'].include?(action_name) ? 'application_main' : 'application_admin'
	end

end
