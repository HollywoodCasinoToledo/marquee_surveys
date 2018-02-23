module AdminsHelper


	def get_head_question(data)
		data = data.to_h.invert
		current = data[nil]
		current = data[current] until data[current].nil?
		current
	end

	def button_class_from_params(key, param)
		key == param ? 'btn btn-default btn-primary' : 'btn btn-default'
	end


end
 