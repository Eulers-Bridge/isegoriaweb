class PollsController < ApplicationController
	def index
		@polls_list = Poll.all
	end

	def new
		@poll = Poll.new #Set a new poll object to be filled by the user form
	end

	def edit
		@poll = Poll.find(params[:id])
	end

	def create
	  @poll = Poll.new(poll_params)
	  if @poll.save
	  	flash[:success] = t(:poll_creation_success_flash, election: @poll.date)
	    redirect_to polls_path
	  else
        flash[:error] = t(:poll_creation_error_flash)
      	@poll = Poll.new
      	redirect_to new_poll_path
	  end
	end

	def update
		@poll = Poll.find(params[:id])
	  if @poll.update_attributes(poll_params)
	  	flash[:success] = t(:poll_modification_success_flash, election: @poll.date)
	    redirect_to polls_path
	  else
        flash[:error] = t(:poll_modification_error_flash)
      	@poll = Poll.new
      	redirect_to edit_poll_path
	  end
	end

	def destroy
	end

		private
    def poll_params
      params.require(:poll).permit(:question, :date, :options, :picture)
    end
end
