class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def include_navigation_pane_variables
		@nav_categories = Category.where(survey_id: 1).to_a.map(&:id)
		@test = Question.all.to_a.map!{ |q| [q.id, q.next_id] }
		@orderized = Array.new
		data = @test.to_h.invert
		current = data[nil]
		@orderized.push(current)
		begin
			current = data[current]
			@orderized.push(current)
		end until data[current].nil?

		@nav_questions = Question.find(@orderized)
  end

end
