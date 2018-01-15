class SurveysController < ApplicationController


	def create
		question = Survey.new(question_params)

		redirect_to controller: :admin, action: :edit_survey
	end

	def new

	end

	private 
		def question_params
			params.require(:question).permit(:survey_id, :title, :style, :required, :parent, :category_id)
		end

end
