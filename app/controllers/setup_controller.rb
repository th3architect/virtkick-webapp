class SetupController < ApplicationController
  layout 'raw'

  # TODO: redirect to / if already set up

  def index

  end

  def perform
    Wvm::Setup.setup

    redirect_to guests_path
  end
end
