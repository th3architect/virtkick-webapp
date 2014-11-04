class SetupController < ApplicationController
  layout 'raw'

  @@ready = false


  def index
    return redirect if @@ready
    Wvm::Setup.check
    redirect
  rescue Wvm::Setup::Error
    render action: :index
  end

  def perform
    Wvm::Setup.check
    render action: 'index'
  rescue Wvm::Setup::Error
    begin
      Wvm::Setup.setup
      unless @demo
        user = User.create_single_user!
        sign_in user
        Wvm::Setup.import_from_libvirt user
      end
      flash[:success] = 'All configured - start VirtKicking now! :-)'
      redirect
    rescue Wvm::Setup::Error => e
      @error = e.message
      render action: :index
    end
  end

  def recheck
    @@ready = false
    index
  end

  private
  def redirect
    @@ready = true
    redirect_to guests_path
  end
end
