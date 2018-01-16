module Exceptions

	class QuestionOrderError < StandardError
		attr_reader :message
	  def initialize(message)
	  	super
	    @message = "Question could not be moved: #{@message}" + message
	  end

	  def to_s
	  	
	  end
	end

end