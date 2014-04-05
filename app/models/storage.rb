class Storage < ActiveRecord::Base
  belongs_to :user
  has_many :items
  has_one :root, -> (storage){ where parent_remote_id: nil}, class_name: 'Item'

  after_initialize :calc_quota_percent_used

  def calc_quota_percent_used
    @quota_used = quota_bytes_used.nil? || quota_bytes_total.nil? ? 0 : (quota_bytes_used.to_f * 100.0 / quota_bytes_total.to_f).round(0)
  end

  def quota_percent_used
    @quota_used
  end

  def as_json(options)
    super(:only => [:id, :provider, :login, :quota_bytes_total, :quota_bytes_used, :picture_url, :etag])
  end

end
