class ResponsesController < ApplicationController

	def create
		params[:answers].each do |k,v|
			answer = Answer.find(k)
			if !answer.nil?
				Response.create(patron_id: session[:patron_id], question_id: answer.question_id, answer_id: answer.id, instance_id: session[:instance_id])
			end
		end

		if !params[:next_question].nil?
			redirect_to controller: :questions, action: :show, id: params[:next_question], previous_question: params[:current_question]
		else
			first_question = Question.find_by(poll_id: poll.id, position: 1)
			redirect_to controller: :votes, action: :confirm, question_id: first_question.id
		end
	end

end
