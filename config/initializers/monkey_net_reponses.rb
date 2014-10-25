require 'net/http'

module Net
  class HTTPResponse
    def ok?
      false
    end

    def success?
      false
    end

    def redirect?
      false
    end
  end

  class HTTPSuccess
    def ok?
      true
    end

    def success?
      true
    end
  end

  class HTTPRedirection
    def ok?
      true
    end

    def redirect?
      true
    end
  end
end
