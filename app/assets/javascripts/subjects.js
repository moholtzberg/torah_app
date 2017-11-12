jQuery(document).on('turbolinks:load', () => {
  if($('#subjects-list').length > 0) {
    fetchSubjects();

    function fetchSubjects() {
      const data = {
        search: {
          name: $('#name').val()
        },
        filters: {
          featured: $('#featured').prop('checked'),
          order_by: $('#order_by').val()
        }
      }

      $('#subjects-list').empty();
      $('#list-loader').show();

      $.get(`${window.location.origin}/subjects/fetch`, data).done((subjects) => {
        $('#list-loader').hide();
        if(subjects ==' ') {
          $('#subjects-list').append("Your search returned no matches.");
        } else {
          $('#subjects-list').append(subjects);
        }
      });
    }

    $('#search-form').change(fetchSubjects);
    $('#order_by').change(fetchSubjects);

    $('#subjects-list').on('click', '.like-button', likeSubject);
    $('#subjects-list').on('click', '.unlike-button', unlikeSubject);
  }

  if($('#subject').length > 0) {
    $('#subject').on('click', '.like-button', likeSubject);
    $('#subject').on('click', '.unlike-button', unlikeSubject);
  }

  function likeSubject(e) {
    e.preventDefault();
    const id = e.target.dataset.id;
    $.post(`${window.location.origin}/add_subject/${id}`)
      .done((response) => {
        $(e.target).toggleClass('like-button unlike-button');
        $(e.target).toggleClass('glyphicon-star-empty glyphicon-star');
      });
  }

  function unlikeSubject(e) {
    e.preventDefault();
    const id = e.target.dataset.id;
    $.ajax({ url: `${window.location.origin}/remove_subject/${id}`, method: 'DELETE'})
      .done((response) => {
        $(e.target).toggleClass('unlike-button like-button');
        $(e.target).toggleClass('glyphicon-star glyphicon-star-empty');
      });
  }

  if($('#subject_picker').length > 0) {
    let searchTimeout;
    fetchSubjectsOptions();

    function fetchSubjectsOptions(search) {
      $.get(`${window.location.origin}/lessons/fetch_subjects`, { search: search})
        .then((lessons) => {
          $('#subject_options').html(lessons);
        });
    }

    $('#subject_picker').on('keyup', (e) => {
      clearTimeout(searchTimeout);
      searchTimeout = setTimeout(() => {
        fetchSubjectsOptions(e.target.value);
      }, 1000);

    })

    $('#subject_picker').on('change', (e)=> {
      const id = $(`#subject_options option[value='${e.target.value}']`).data('id');
      $('#lesson_subject_id').val(id);
      $('#subject_parent_id').val(id);
    });
  }
});
