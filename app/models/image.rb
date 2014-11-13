require 'active_hash'
require 'httparty'

class Image < ActiveYaml::Base
  set_root_path 'app/models'

  field :name
  field :description
  field :stars
  field :avatar
end
