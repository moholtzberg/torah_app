jQuery(document).on('turbolinks:load', () => {
  $('#subjects-list').on('click', '.like-button', likeSubject);
  $('#subjects-list').on('click', '.unlike-button', unlikeSubject);

  function likeSubject(e) {
    e.preventDefault();
    const id = e.target.dataset.id;
    $.post(`${window.location.origin}/add_subject/${id}`)
      .done((response) => {
        $(e.target).html('Unlike');
        $(e.target).toggleClass('like-button unlike-button');
      });
  }

  function unlikeSubject(e) {
    e.preventDefault();
    const id = e.target.dataset.id;
    $.ajax({ url: `${window.location.origin}/remove_subject/${id}`, method: 'DELETE'})
      .done((response) => {
        $(e.target).html('Like');
        $(e.target).toggleClass('unlike-button like-button');
      });
  }

  if($('#subject_picker').length > 0) {
    let searchTimeout;
    fetchSubjects();

    function fetchSubjects(search) {
      $.get(`${window.location.origin}/lessons/fetch_subjects`, { search: search})
        .then((lessons) => {
          $('#subject_options').html(lessons);
        });
    }

    $('#subject_picker').on('keyup', (e) => {
      clearTimeout(searchTimeout);
      searchTimeout = setTimeout(() => {
        fetchSubjects(e.target.value);
      }, 1000);

    })

    $('#subject_picker').on('change', (e)=> {
      const id = $(`#subject_options option[value='${e.target.value}']`).data('id');
      $('#lesson_subject_id').val(id);
      $('#subject_parent_id').val(id);
    });
  }
});
