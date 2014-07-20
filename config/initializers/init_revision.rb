revision_path = Rails.root.join("REVISION_DEPLOYED")
Rails.configuration.revision = if File.exists?(revision_path)
  File.read(revision_path).strip
else
  "-"
end
Rails.configuration.started_at = Time.now.utc

