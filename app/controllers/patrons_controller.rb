class PatronsController < ApplicationController

	layout 'application_main'

	def home
			redirect_to controller: :questions, action: :show, id: Question.find_by(active: true, position: 1).id
	end

end
