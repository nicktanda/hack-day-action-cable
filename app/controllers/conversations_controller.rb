class ConversationsController < ApplicationController
  def index; end

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages.includes(:user)
  end

  def create
    conversation = Conversation.create!(user: current_user)
    message = Message.new(body: params[:message][:body], conversation_id: conversation.id, user_id: current_user.id)
    
    if message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to show_conversation_path(conversation) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
end