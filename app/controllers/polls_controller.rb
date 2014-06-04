class PollsController < ApplicationController
	def index
		@polls_list = Poll.all
	end

	def new
		@poll = Poll.new #Set a new poll object to be filled by the user form
	end

	def edit
	end

	def create
	  @poll = Poll.new(poll_params)
	  if @poll.save
	  	flash[:success] = t(:poll_creation_success_flash, election: @poll.date)
	    redirect_to edit_poll_path
	  else
        flash[:error] = t(:poll_creation_error_flash)
      	@poll = Poll.new
      	redirect_to new_poll_path
	  end
	end

	def update
	end

	def destroy
	end

		private
    def poll_params
      params.require(:poll).permit(:question, :date, :options, :picture)
    end
end
