class CommentsController < ApplicationController

	def create
		Comment.create(patron_id: session[:patron_id], question_id: params[:current_question], comment: params[:comment], instance_id: session[:instance_id])

		order = Array.new
		order.push(params[:order].split(",")) if !params[:order].blank?
		order.push(params[:current_question])

		if !params[:next_question].nil?
			redirect_to controller: :questions, action: :show, id: params[:next_question], order: order.join(",")
		else
			first_question = Question.find_by( position: 1)
			redirect_to controller: :surveys, action: :confirm
		end
	end

end
