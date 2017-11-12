jQuery(document).on('turbolinks:load', function() {
  App.current_user = App.cable.subscriptions.create({
      channel: 'CurrentUserChannel'
    }, {
    received: function(data) {
      const counter = $('#unread-notifications-count');
      counter.html(1 + Number(counter.text()));
    }
  });
});
