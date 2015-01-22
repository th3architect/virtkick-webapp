describe CountDeploymentJob do
  it 'counts a deployment' do
    # given
    stub_count_deployment_with_status 200
    # when
    CountDeploymentJob.track 'test'
    # then
    expect(Setting.find_by_key 'tracking_test').to eq 't'
  end

  it 'doesnt count deployment twice' do
    # given
    stub_count_deployment_with_status 200
    # when
    CountDeploymentJob.track 'test'
    CountDeploymentJob.track 'test'
    # then
    expect(Setting.find_by_key 'tracking_test').to eq 't'
    expect(a_request(:post, 'https://stats.virtkick.io/count_deployment').with(&req_spec)).to have_been_made.once
  end

  it 'throws an exception when request fails' do
    # given
    stub_count_deployment_with_status 500
    # when
    expect { CountDeploymentJob.track 'test' }.to \
        raise_error RuntimeError, 'HTTP request failed'
    # then
    expect(Setting.find_by_key 'tracking_test').to eq nil
  end


  before do
    WebMock.disable_net_connect!
  end

  after do
    WebMock.allow_net_connect!
    WebMock.reset!
  end

  let(:req_spec) do
    Proc.new do |req|
      req.body == {event: 'test'}.to_json && req.headers['X-Techstars'] == 'San Antonio'
    end
  end

  private
  def stub_count_deployment_with_status status
    stub_request(:post, 'https://stats.virtkick.io/count_deployment').
        with(&req_spec).
        to_return status: status
  end
end
