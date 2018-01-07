jQuery(document).on('turbolinks:load', function() {
  if ($('#chatroom').length > 0) {
    const messages = $('#messages');
    const chatroom_id = messages.data('chatroom-id')
    const current_user_id = $('#current_user').data('id');

    showUserMessagesEditButton(current_user_id);
    messages_to_bottom();

    function showUserMessagesEditButton(id) {
      $(`.msg[data-author-id="${id}"] .edit-message`).show();
    }

    function messages_to_bottom() {
      messages.scrollTop(messages.prop('scrollHeight'));
    }

    App.global_chat = App.cable.subscriptions.create({
      channel: 'ChatroomsChannel',
      chatroom_id: chatroom_id
    }, {
      received: function(data) {
        const message = $(data['message']);
        if (message.data('author-id') == current_user_id) {
          message.find('.edit-message').show();
        } else {
          playNewMessageSound();
        }
        const oldMessage = document.querySelector(`.msg[data-id="${data['id']}"]`)
        if (oldMessage) {
          $(oldMessage).replaceWith(message);
        } else {
          messages.append(message);
          messages_to_bottom();
        }
      },

      send_message: function(message, chatroom_id) {
        this.perform('send_message', {
          message,
          chatroom_id
        });
      },

      edit_message: function(id, new_message) {
        this.perform('edit_message', {
          id,
          new_message
        });
      },

      start_video_call: function(chatroom_id) {
        this.perform('start_video_call', {
          chatroom_id
        });
      }
    });

    function playNewMessageSound() {
      const audio = new Audio(`${window.location.origin}/sounds/new_message.mp3`);
      audio.play().catch(() => console.log("Your browser cannot play sound on background"));
    }

    function openMessageEditForm(e) {
      const message = $(e.target).parents('.msg');
      message.find('.msg-body').hide();
      messages.find('.edit-form').hide();
      message.find('.edit-form').show()
        .on('submit', editMessage);
      message.find('.edit-form-cancel')
        .on('click', closeMessageEditForm);
    }

    function closeMessageEditForm(e) {
      const message = $(e.target).parents('.msg');
      message.find('.msg-body').show();
      messages.find('.edit-form').hide();
    }

    function editMessage(e) {
      e.preventDefault();
      App.global_chat.edit_message(
        $(e.target).find('*[name="message[id]"]').val(),
        $(e.target).find('*[name="message[body]"]').val()
      );
    }

    messages.on('click', '.edit-message', openMessageEditForm);

    $('#new_message').submit((e) => {
      e.preventDefault();
      const textarea = $('#new_message #message_body');
      if (textarea.val().length > 1) {
        App.global_chat.send_message(textarea.val(), chatroom_id);
        textarea.val('');
      }
    });
  }
});
