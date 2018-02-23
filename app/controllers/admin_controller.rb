class AdminController < ApplicationController
	include AdminsHelper 
	layout 'application_admin'

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
		@answers = Answer.where(question_id: @question.id)
		@responses = Response.where(question_id: @question.id)
		if params[:onlyshow] == "Members"
			@responses = @responses.where.not(patron_id: nil)
		elsif params[:onlyshow] == "Anon"
			@responses = @responses.where(patron_id: nil)
		end
		@answer_totals = @responses.group(:answer_id).count

		if !params[:from].blank?
			@day_data = @responses.created_after(params[:from]).created_before(params[:to]).group_by(&:group_by_date).map {|k,v| [k, v.length]}.sort
		end
		
	end

	def group_by_criteria
	  created_at.to_date.to_s(:db)
	end

end
