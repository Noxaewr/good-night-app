# frozen_string_literal: true

class UserContract < ApplicationContract
  params do
    required(:name).filled(:string)
  end

  rule(:name) do
    key.failure('must be at least 2 characters long') if value.length < 2
    key.failure('must be at most 100 characters long') if value.length > 100
  end
end
