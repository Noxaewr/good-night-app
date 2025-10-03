# frozen_string_literal: true

class ApplicationService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  private_class_method :new
end
