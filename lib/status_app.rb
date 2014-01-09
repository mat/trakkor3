require "json"

class StatusApp
  def self.call(env)
    config = Rails.configuration

    status = {
      ruby_description: RUBY_DESCRIPTION,
      rails_version:    Rails.version,
      rails_env:        Rails.env,
      hostname:         hostname,
      revision:         config.revision,
      started_at:       config.started_at,
      started_ago:      "%.2f minutes ago" % [(Time.now - config.started_at) / 60.0],
    }
    [code=200, {}, [JSON.dump(status)]]
  end

  def self.hostname
    `hostname`.strip
  end
end

