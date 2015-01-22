class Setting < ActiveRecord::Base
  def self.find_by_key key
    Setting.where(key: key).first.val rescue nil
  end
end
