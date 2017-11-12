jQuery(document).on('turbolinks:load', () => {
  $('#get-notifications').on('click', () => {
    $.ajax({
            url: "/notifications?limit=5",
            dataType: "JSON",
            method: "GET"
        })
      .then((notifications) => {
        const items = notifications.map((n) => `<li class="dropdown-item"><a href="${n.link}">${n.message}</a></li>`);
        $('#notifications-small-list').html(items.join(' '));
        $.post('/notifications/mark_as_read')
          .then(() => {
            $('#unread-notifications-count').html('0');
          });
      });
  });

  if (!window.subscribedToPushNotifications && 'serviceWorker' in navigator) {
    console.log('Service Worker is supported');
    navigator.serviceWorker.register('/serviceworker.js')
      .then((reg) => {
        console.log('Successfully registered!', ':^)', reg);
        reg.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: window.vapidPublicKey
          })
          .then((sub) => {
            console.log('Successfully subscribed!', ':^)', sub.endpoint);
            $.post("/notifications/subscribe", {
              subscription: sub.toJSON()
            });
          });

      }).catch((error) => {
        console.log('Registration failed', ':^(', error);
      });

    function unsubscribe() {
      navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
        serviceWorkerRegistration.pushManager.getSubscription()
          .then((subscription) => {
            if (!subscription) {
              console.log("Not subscribed, nothing to do.");
              return;
            }

            subscription.unsubscribe()
              .then(() => console.log("Successfully unsubscribed!."))
              .catch((e) => {
                logger.error('Error thrown while unsubscribing from push messaging', e);
              });
          });
      });
    }

  }
});
