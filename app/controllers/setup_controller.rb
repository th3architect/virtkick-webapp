class SetupController < ApplicationController
  layout 'raw'

  @@ready = false


  def index
    return redirect if @@ready
    Wvm::Setup.check
    redirect
  rescue Wvm::Setup::Error => e
    @error = e.message # TODO: remove
  end

  def perform
    Wvm::Setup.check
    render action: 'index'
  rescue Wvm::Setup::Error => e
    Wvm::Setup.setup
    redirect
  end

  def recheck
    @@ready = false
    index
    render action: :index
  end

  private
  def redirect
    @@ready = true
    redirect_to guests_path
  end
end
