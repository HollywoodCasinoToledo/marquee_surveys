class CategoriesController < ApplicationController

	layout 'application_admin'

	def create
		category = Category.new(category_params)
		category.property_id = 25
		category.survey_id = 1
		category.save!
		redirect_to controller: :admin, action: :control_panel
	end

	def new
		@selection_hash = Hash.new
		@selection_hash.default = []
		Answer.joins(:question).where('questions.survey_id = ?', 1).each do |a|
			q = Question.find(a.question_id)
			if @selection_hash.include? q.title
				@selection_hash[q.title].push [a.title, a.id.to_s]
			else
				@selection_hash[q.title] = [[a.title, a.id.to_s]]
			end
		end
	end

	private 
		def category_params
			params.require(:category).permit(:name, :parent)
		end
end
