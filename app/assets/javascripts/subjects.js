jQuery(document).on('turbolinks:load', () => {
  if ($('#subjects-list').length > 0) {
    const getData = (page) => ({
      page: page,
      search: {
        name: $('#name').val()
      },
      filters: {
        featured: $('#featured').prop('checked'),
        order_by: $('#order_by').val()
      }
    });

    new InfinityList({
      selector: "#subjects-list",
      url: "/subjects/fetch",
      getData: getData,
      per_page: 10
    });

    $('#subjects-list').on('click', '.like-button', likeSubject);
    $('#subjects-list').on('click', '.unlike-button', unlikeSubject);
  }

  if ($('#subject').length > 0) {
    $('#subject').on('click', '.like-button', likeSubject);
    $('#subject').on('click', '.unlike-button', unlikeSubject);
  }

  if ($('#favorites-list').length > 0) {
    const getData = (page) => ({
      page: page
    });

    const userId = $('#favorites-list').data("id");

    new InfinityList({
      selector: "#favorites-list",
      url: `/users/${userId}/favorites`,
      getData: getData,
      per_page: 25
    });


    $('#favorites-list').on('click', '.like-button', likeSubject);
    $('#favorites-list').on('click', '.unlike-button', unlikeSubject);
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
    $.ajax({
        url: `${window.location.origin}/remove_subject/${id}`,
        method: 'DELETE'
      })
      .done((response) => {
        $(e.target).toggleClass('unlike-button like-button');
        $(e.target).toggleClass('glyphicon-star glyphicon-star-empty');
      });
  }
});
