class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def include_navigation_pane_variables
		@nav_categories = Category.where(survey_id: 1).to_a.map(&:id)
		@nav_questions = Question.order(:position)
		@nav_category_starts = Question.where.not(category_id: nil).order(position: :asc).group(:category_id).map(&:id)
  end

end
