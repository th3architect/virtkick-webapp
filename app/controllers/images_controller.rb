class ImagesController < ApplicationController
  before_action :authenticate_user!

  respond_to :html
  respond_to :json

  def index
    @images = if params[:search]
      DockerIndexBrowser.new.search params[:search]
    else
      Image.all
    end
  end
end
