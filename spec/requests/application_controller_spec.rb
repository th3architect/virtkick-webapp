describe 'Demo sessions' do
  before do
    Rails.configuration.x.demo = true
    Rails.configuration.x.demo_timeout = 5
  end

  after do
    Rails.configuration.x.demo = false
  end

  it 'logs out after timeout' do
    post guests_path
    expect(response).to redirect_to machines_path

    get machines_path
    expect(response).to render_template :index

    Timecop.travel 5.minutes

    get machines_path
    expect(response).to redirect_to '/'
  end
end
