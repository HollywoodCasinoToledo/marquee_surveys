module Exceptions

	class QuestionOrderError < StandardError
		attr_reader :message
	  def initialize(message)
	  	super
	    @message = message
	  end

	  def to_s
	  	"Question could not be moved: #{@message}"
	  end
	end

end