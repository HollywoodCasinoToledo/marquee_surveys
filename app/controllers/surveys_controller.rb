class SurveysController < ApplicationController

	layout :decide_layout

	def confirm
		@redirect_time = 3 #seconds
	end

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

	def decide_layout
		['create', 'new'].include?(action_name) ? 'application_admin' : 'application_main'
	end

end
