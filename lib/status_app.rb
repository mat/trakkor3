require "nokogiri"

class StatusApp
  def self.call(env)
    config = Rails.configuration

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.status {
        xml.ruby_description RUBY_DESCRIPTION
        xml.rails_version Rails.version
        xml.rails_env Rails.env
        xml.hostname hostname
        xml.revision config.revision
        xml.started_at config.started_at
        xml.started_ago  "%.2f minutes ago" % [(Time.now - config.started_at) / 60.0]
      }
    end

    [code=200, {}, [builder.to_xml]]
  end

  def self.hostname
    `hostname`.strip
  end
end

