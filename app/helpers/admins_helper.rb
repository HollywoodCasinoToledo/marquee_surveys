module AdminsHelper


	def get_head_question(data)
		data = data.to_h.invert
		current = data[nil]
		current = data[current] until data[current].nil?
		current
	end


end
 