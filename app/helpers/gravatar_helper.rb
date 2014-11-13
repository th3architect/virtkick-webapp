require 'openssl'
require 'securerandom'

module GravatarHelper
  def gravatar_for email, options = {}
      options = {alt: 'avatar', class: 'avatar', size: 80}.merge! options
      id = options[:md5] ? email : Digest::MD5::hexdigest(email.strip.downcase)
      url = 'http://www.gravatar.com/avatar/' + id + '.jpg?s=' + options[:size].to_s
      options.delete :size
      image_tag url, options
  end
end
