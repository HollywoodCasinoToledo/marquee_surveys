class AnswersController < ApplicationController

	layout 'application_admin'

	def create
		answer = Answer.new(answer_params)
		@question = Question.find(params[:answer][:question_id])
		if answer.save
			flash[:title] = "Success"
			flash[:notice] = "Answer created"
			redirect_to controller: :admin, action: :edit_survey
		else
			flash[:title] = "Error"
			flash[:notice] = answers.errors.messages
			redirect_to controller: :admin, action: :edit_survey
		end
	end

	def new
		include_navigation_pane_variables
		
		@question = Question.find(params[:question])
	end
	
	private
		def answer_params
			params.require(:answer).permit(:title, :picture, :question_id)
		end
	
end
