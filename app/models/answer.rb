class Answer < ActiveRecord::Base
	belongs_to :question

	def self.as_select_hash(survey_id)
		@selection_hash = Hash.new
		@selection_hash.default = []
		questions = Question.order(:position).to_a.map(&:id)
		Question.where(id: questions).each_with_index do |q, i|
			pos = (i.to_i + 1).to_s + ". "
			a = Answer.where(question_id: q.id).each do |a|
				if @selection_hash.include? pos + q.title
					@selection_hash[pos + q.title].push [a.title, a.id.to_s]
				else
					@selection_hash[pos + q.title] = [[a.title, a.id.to_s]]
				end
			end
		end
		return @selection_hash
	end

	def self.autogenerate

	end

end
