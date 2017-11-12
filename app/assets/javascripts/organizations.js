jQuery(document).on('turbolinks:load', () => {
  if ($('#organizations-list').length > 0) {
    fetchOrganizations();

    function fetchOrganizations() {
      const data = {
        search: {
          name: $('#name').val()
        },
        filters: {
          order_by: $('#order_by').val()
        }
      };

      $('#organizations-list').empty();
      $('#list-loader').show();

      $.get(`${window.location.origin}/organizations/fetch`, data).done((organizations) => {
        $('#list-loader').hide();
        if (organizations == ' ') {
          $('#organizations-list').append("Your search returned no matches.");
        } else {
          $('#organizations-list').append(organizations);
        }
      });
    }

    $('#search-form').change(fetchOrganizations);
    $('#order_by').change(fetchOrganizations);
  }
});
