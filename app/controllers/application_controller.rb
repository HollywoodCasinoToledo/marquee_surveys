class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def include_navigation_pane_variables
		@navigation_data = Array.new
		questions = Question.where(active: true).order(:position).map(&:category_id).map! { |x| x.nil? ? 0 : x }.chunk{|n| n }.to_a.map{ |x| x[0] != 0 ? x[0] : x[1]}.flatten
		uncategorized_questions = Question.where(active:true, survey_id: 1, category_id: nil).map(&:id)
		questions.each do |x| 
			if x == 0
				@navigation_data.push(uncategorized_questions.shift)
			else
				@navigation_data.push({Category.find(x).name => Question.where(active: true, category_id: x).order(:position).map(&:id)})
			end
		end
  end

  def authenticate_user_is_admin
		if !session[:granted].nil? && session[:granted]
			return true
		else
			flash[:title] = "Error"
	  	flash[:notice] = "Enter password to accessd admin privileges."
	    redirect_to controller: :admin, action: :access
	    return false
		end
	end	

end
