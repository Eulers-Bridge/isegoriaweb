class ElectionsController < ApplicationController
	def new
		@election = Election.new #Set a new election object to be filled by the user form
	end

	def edit
		@election = Election.find(params[:id])
	end

	def create
		@election = Election.new(election_params)
	  if @election.save
	  	flash[:success] = t(:election_creation_success_flash, election: @election.title)
	    redirect_to edit_election_path
	  else
        flash[:error] = t(:election_creation_error_flash)
      	@election = Election.new
      	redirect_to new_election_path
	  end
	end

	def update
		@election = Election.find(params[:id])
	  if @election.update_params(election_params)
	  	flash[:success] = t(:election_modification_success_flash, election: @election.title)
	    redirect_to edit_election_path
	  else
        flash[:error] = t(:election_modification_error_flash)
      	@election = Election.new
      	redirect_to edit_election_path
	  end
	end

	def destroy
	end

	def verify_existence
	  if false #an election has been created before
	    redirect_to edit_election_path(:id => 1)
	  else
	    redirect_to new_election_path
      end
	end

	private
    def election_params
      params.require(:election).permit(:title, :description, :process_image, :positions)
    end
end
