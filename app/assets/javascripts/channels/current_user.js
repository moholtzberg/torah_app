jQuery(document).on('turbolinks:load', function() {
  App.current_user = App.cable.subscriptions.create({
      channel: 'CurrentUserChannel'
    }, {
    received: function(data) {
      if(data.type == 'video_call') {
        createVideoCallDiv(data);
      } else {
        const counter = $('#unread-notifications-count');
        counter.html(1 + Number(counter.text()));
      }
    }
  });

  function createVideoCallDiv(data) {
    const div = `
      <div class='overlay'></div>
      <div id='video-call-ring'>
        <div><img src='/images/phone_ring.png' class='chatroom-avatar'></div>
        <br>
        <audio id="ring" src="/sounds/phone_ring.mp3" preload="auto"></audio>
        <h4>${data.user} is calling you</h4>
        <a href='${data.chatroom.url}' class='btn btn-success'>Go to chatroom</a>
        <a id='cancel-video-call' class='btn btn-danger'>Cancel</a>
      </div>
    `

    $('body').append(div);
    document.getElementById('ring').play();
    const closeDivTimeout = setTimeout(removeVideoCallDiv, 30000);
    $('#cancel-video-call').on('click', () => {
      clearTimeout(closeDivTimeout);
      removeVideoCallDiv();
    });
  }

  function removeVideoCallDiv() {
    $('#video-call-ring').remove();
    $('.overlay').remove();
  }
});
