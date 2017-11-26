jQuery(document).on('turbolinks:load', () => {
  if ($('#admin-organizations-list').length > 0) {
    const getData = (page) => ({
      page: page,
      search: {
        name: $('#name').val()
      },
      filters: {
        order_by: $('#order_by').val(),
        confirmed: $('#confirmed').prop('checked'),
        unconfirmed: $('#unconfirmed').prop('checked')
      }
    });

    new InfinityList({
      selector: "#admin-organizations-list",
      url: "/admin/organizations/fetch",
      getData: getData,
      per_page: 10
    });
  }

  if ($('#organizations-list').length > 0) {
    const getData = (page) => ({
      page: page,
      search: {
        name: $('#name').val()
      },
      filters: {
        order_by: $('#order_by').val()
      }
    });

    new InfinityList({
      selector: "#organizations-list",
      url: "/organizations/fetch",
      getData: getData,
      per_page: 10
    });
  }
});
