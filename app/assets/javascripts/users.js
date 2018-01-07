jQuery(document).on('turbolinks:load', () => {
  if ($('#users-list').length > 0) {
    const getData = (page) => ({
      page: page,
      search: {
        name: $('#name').val(),
        country: $('#country').val(),
        city: $('#city').val(),
        state: $('#state').val(),
        language: $('#language').val()
      },
      filters: {
        online: $('#online').prop('checked'),
        order_by: $('#order_by').val()
      }
    });

    new InfinityList({
      selector: "#users-list",
      url: "/users/fetch",
      getData: getData,
      per_page: 25
    });
  }

if ($('.edit_user').length > 0) {
  const languageInput = createLanguagePicker("#user_language");

  $('input.time').timepicker({
    showDuration: true,
    timeFormat: 'H:i',
    disableTextInput: true
  });

  $('.day').datepair();

  $('.edit_user').on('submit', (e) => {
    $('.day').each((i, day) => {
      const range = `${$(day).find('.start').val()}..${$(day).find('.end').val()}`;
      $(day).find('#user_availability').val(range);
    });
  });
}
});
