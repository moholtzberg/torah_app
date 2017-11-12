self.addEventListener("push", function(event) {
  const json = event.data.json();
  self.registration.showNotification("Torah-app", {
    icon: "/images/notification_icon.png",
    body: json.body,
    data: {
      url: json.url
    },
    tag: "new-message"
  });
});

self.addEventListener('notificationclick', function(event) {
  console.log('On notification click: ', event.notification.tag);
  const url = event.notification.data.url;
  event.notification.close();
  event.waitUntil(
    clients.matchAll({
      type: "window"
    })
    .then(function(clientList) {
      for (var i = 0; i < clientList.length; i++) {
        var client = clientList[i];
        if (client.url == url && 'focus' in client)
          return client.focus();
      }
      if (clients.openWindow) {
        return clients.openWindow(url);
      }
    })
  );
});
