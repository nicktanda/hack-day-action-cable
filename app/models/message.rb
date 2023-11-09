class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  default_scope { order(created_at: :desc) }
  broadcasts_to ->(message) { [message.conversation, "messages"] }, inserts_by: :prepend, partial: "conversations/message"
end