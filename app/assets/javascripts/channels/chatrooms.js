jQuery(document).on('turbolinks:load', function() {
  const messages = $('#messages');
  const chatroom_id = messages.data('chatroom-id')

  messages_to_bottom();

  function messages_to_bottom() {
    messages.scrollTop(messages.prop('scrollHeight'));
  }

  App.global_chat = App.cable.subscriptions.create({
      channel: 'ChatroomsChannel',
      chatroom_id: chatroom_id
    }, {
    received(data) {
      messages.append(data['message']);
      messages_to_bottom();
    },

    send_message(message, chatroom_id) {
      this.perform('send_message', {message, chatroom_id});
    },

    start_video_call(chatroom_id) {
      this.perform('start_video_call', {chatroom_id});
    }
  });

  $('#new_message').submit((e) => {
    e.preventDefault();
    const textarea = $('#message_body');
    if (textarea.val().length > 1) {
      App.global_chat.send_message(textarea.val(), chatroom_id);
      textarea.val('');
    }
  });
});
