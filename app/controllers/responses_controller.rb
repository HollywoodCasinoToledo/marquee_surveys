class ResponsesController < ApplicationController

	def create
		if params[:next_question].nil?
			first_question = Question.find_by(poll_id: poll.id, position: 1)
			redirect_to controller: :votes, action: :confirm, question_id: first_question.id
		else
			redirect_to controller: :questions, action: :show, id: params[:next_question]
		end
	end

end
