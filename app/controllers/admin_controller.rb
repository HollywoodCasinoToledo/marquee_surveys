class AdminController < ApplicationController
	include AdminsHelper 
	layout 'application_admin'

	def control_panel
		
	end

	def edit_survey
		include_navigation_pane_variables
		
		@categories = Category.where(survey_id: 1).to_a.map(&:id)
		@test = Question.all.to_a.map!{ |q| [q.id, q.next_id] }
		@orderized = Array.new
		data = @test.to_h.invert
		current = data[nil]
		@orderized.push(current)
		begin
			current = data[current]
			@orderized.push(current)
		end until data[current].nil?

		@questions = Question.find(@orderized)
	end

end
