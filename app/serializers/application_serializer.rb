# frozen_string_literal: true

# Base serializer for all serializers
class ApplicationSerializer
  include JSONAPI::Serializer

  def self.float_attribute(attribute_name)
    attribute attribute_name do |object|
      object.send(attribute_name).to_f
    end
  end
end
