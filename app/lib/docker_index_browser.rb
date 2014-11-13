class DockerIndexBrowser
  def initialize url = 'https://index.docker.io'
    @url = url
  end

  def search phrase
    resp = HTTParty.get "#{@url}/v1/search", query: {q: phrase}

    raise unless resp.response.ok?

    images = resp.parsed_response['results'].map do |image|
      Image.new \
        name: image['name'],
          description: image['description'],
          stars: image['star_count']
    end

    images.sort { |e, f| f.stars <=> e.stars } # it's reversed
  end
end
