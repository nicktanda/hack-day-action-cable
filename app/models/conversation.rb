class Conversation < ApplicationRecord
  has_many :messages

  has_many :conversation_user_joins, dependent: :destroy
  has_many :users, through: :conversation_user_joins, dependent: :destroy
end