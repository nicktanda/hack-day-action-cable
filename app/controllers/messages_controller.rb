class MessagesController < ApplicationController
  include ActionView::RecordIdentifier

  def create
    @conversation = Conversation.find(params[:message][:conversation_id])
    @message = Message.new(body: params[:message][:body], conversation_id: @conversation.id, user_id: current_user.id)

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to show_conversation_path(@conversation.id) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
end

