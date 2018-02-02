class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def include_navigation_pane_variables
		@navigation_data = Array.new
		questions = Question.where(active: true).order(:position).map(&:category_id).map! { |x| x.nil? ? 0 : x }.chunk{|n| n}.map(&:first)
		uncategorized_questions = Question.where(survey_id: 1, category_id: nil).map(&:id)
		questions.each do |x| 
			if x == 0
				@navigation_data.push(uncategorized_questions.shift)
			else
				@navigation_data.push({Category.find(x).name => Question.where(category_id: x).order(:position).map(&:id)})
			end
		end
  end

end
