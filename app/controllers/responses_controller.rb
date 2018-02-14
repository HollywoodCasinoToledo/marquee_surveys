class ResponsesController < ApplicationController

	def create
		if !params[:answers].nil?
			params[:answers].each do |k,v|
				answer = Answer.find(k)
				if !answer.nil?
					Response.create(patron_id: session[:patron_id], question_id: answer.question_id, answer_id: answer.id, instance_id: session[:instance_id])
				end
			end
		end

		if !params[:next_question].nil?
			redirect_to controller: :questions, action: :show, id: params[:next_question]
		else
			first_question = Question.find_by( position: 1)
			redirect_to controller: :questions, action: :show, id: first_question.id
		end
	end

end
