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

	def delete

	end

	def edit
		include_navigation_pane_variables
		@answer = Answer.find(params[:id])
		@question = Question.find(@answer.question_id)
	end

	def new
		include_navigation_pane_variables
		@question = Question.find(params[:question])
	end

	def update
		answer = Answer.find(params[:id])
		answer.update_attributes(answer_params)
		flash[:title] = "Success"
		flash[:notice] = "Answer changed"
		redirect_to controller: :admin, action: :edit_survey
	end
	
	private
		def answer_params
			params.require(:answer).permit(:title, :picture, :question_id)
		end
	
end
