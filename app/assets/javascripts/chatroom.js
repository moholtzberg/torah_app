jQuery(document).on('turbolinks:load', function() {
  const chatroom_id = $('#messages').data('chatroom-id');

  function getToken(chatroom_id) {
    return $.get('video_token/' + chatroom_id);
  }

  function createRoom(room) {
    console.log('Successfully joined a Room: ', room);

    showCurrentUserWebcam();

    room.participants.forEach(showParticipant);

    room.on('participantConnected', connectParticipant);

    room.on('participantDisconnected', disconnectParticipant);

    room.on('disconnected', removeLocalTracks);

    $('#hang-up-button').on('click', () => disconnectFromVideoChat(room));
  }

  function removeLocalTracks(room) {
    room.localParticipant.tracks.forEach(track => {
      var attachedElements = track.detach();
      attachedElements.forEach(element => element.remove());
    });
    console.log('You have been disconected from Room');
  }

  function roomErrors(error) {
    console.error('Unable to connect to Room: ' +  error.message);
  }

  function connectParticipant(participant) {
    console.log('A remote Participant connected: ', participant);
    showParticipant(participant);
  }

  function disconnectParticipant(participant) {
    console.log('A remote Participant disconnected: ', participant);
    hideParticipant(participant);
    showDisconnectedParticipantInChat(participant);
  }

  function showDisconnectedParticipantInChat(participant) {
    const name = participant.identity.split("_", 1)
    $('#messages').append(`<span>${name} has disconnected from video chat</span>`)
  }

  function showParticipant(participant){
    let div = findParticipantDiv(participant);
    if (div) {
      div.innerHTML = '';
    } else {
      div = participantDiv(participant);
      $('#participants-webcams').append(div);
    }

    participant.on('trackAdded', (track) => {
      div.appendChild(track.attach());
    });
  }

  function hideParticipant(participant){
    let div = findParticipantDiv(participant);
    if (div) {
      div.remove();
    }
  }

  function findParticipantDiv(participant) {
    return document.querySelector(`.webcam[data-identity~="${participant.identity}"]`)
  }

  function participantDiv(participant) {
    const div = document.createElement('div');
    div.dataset.identity = participant.identity;
    div.className = 'webcam';
    return div;
  }

  function showCurrentUserWebcam() {
    $('#webcam-preview').html('');
    Twilio.Video.createLocalTracks().then((localTracks) => {
      localTracks.forEach((track) => {
        $('#webcam-preview').append(track.attach());
      });
    });
  }

  function connectToVideoChat() {
    getToken(chatroom_id).then((data) => {
      Twilio.Video.connect(data.token, {name:'chatroom_' + chatroom_id})
        .then(createRoom, roomErrors);
    });

    showVideoChat();

    App.global_chat.start_video_call(chatroom_id);
  }

  function disconnectFromVideoChat(room) {
    hideVideoChat();
    room.disconnect();
  }

  function showVideoChat() {
    $('#video-chat').show().addClass('col-lg-8');
    $('#chatroom').addClass('col-lg-4');
  }

  function hideVideoChat() {
    $('#video-chat').hide().removeClass('col-lg-8');
    $('#chatroom').removeClass('col-lg-4');
  }

  $('#call-button').on('click', connectToVideoChat);

  $('#messages').on('click', '.video-call-link', connectToVideoChat);
});
