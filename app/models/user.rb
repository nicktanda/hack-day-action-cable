class User < ApplicationRecord
  has_many :conversation_user_joins, dependent: :destroy
  has_many :conversations, through: :conversation_user_joins, dependent: :destroy

  has_many :messages

  has_secure_password
end
