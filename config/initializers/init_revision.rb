Rails.configuration.revision = ENV["REVISION_DEPLOYED"].presence || "-"
Rails.configuration.started_at = Time.now.utc
