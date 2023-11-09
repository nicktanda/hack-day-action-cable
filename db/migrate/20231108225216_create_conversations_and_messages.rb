class CreateConversationsAndMessages < ActiveRecord::Migration[7.0]
  def change    
    create_table :conversations do |t|
      t.timestamps
    end

    create_table :messages do |t|
      t.string :body, null: false
      t.references :user, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end

    create_table :conversation_user_joins do |t|
      t.references :user, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
