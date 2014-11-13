describe Image do
  let(:index) { DockerIndexBrowser.new }

  before do
    WebMock.disable_net_connect!
  end

  after do
    WebMock.allow_net_connect!
    WebMock.reset!
  end

  it 'performs real search in Docker Index' do
    stub 'virtkick-unit-test'
    images = index.search 'virtkick-unit-test'
    expect(images.size).to eq 1

    image = images.first
    expect(image.name).to eq 'nowaker/virtkick-unit-test'
    expect(image.description).to eq 'Ignore this repo.'
    expect(image.stars).to be_truthy
    expect(image.avatar).to be_nil
  end

  it 'sorts images by number of stars' do
    stub 'openstack'

    images = index.search 'openstack'
    expect(images.size).to eq 32
    expect(images.first.name).to eq 'ewindisch/dockenstack'
  end

  def stub query
    desc = self.class.description.downcase
    json = File.read "spec/fixtures/#{desc}/#{query}.json"
    stub_request(:any, "https://index.docker.io/v1/search?q=#{query}").to_return \
        body: json, headers: {content_type: 'application/json'}
  end
end
