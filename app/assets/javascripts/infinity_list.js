class InfinityList {
  constructor(options={}) {
    this.list = $(options.selector);
    this.url = options.url;
    this.getData = options.getData;
    this.per_page = options.per_page;
    this.isFetching = false;
    this.lastPage = false;

    this.fetchData(1);

    $(window).on('scroll', () => {
        const next_page =  Math.round(this.list.children('li').length / this.per_page) + 1;
        if (next_page && $(window).scrollTop() > $(document).height() - $(window).height() - 60) {
          this.fetchData(next_page);
        }
    });

    $('#search-form').change(() => this.resetList());
    $('#order_by').change(() => this.resetList());
  }

  resetList() {
    console.log("Reset list")
    this.lastPage = false;
    this.list.empty();
    this.fetchData(1)
  }

  fetchData(page) {
    if(this.isFetching || this.lastPage) {
      return false;
    }

    this.isFetching = true;
    $('#list-loader').show();

    console.log("page", page);
    $.get(this.url, this.getData(page)).done((data) => {
      $('#list-loader').hide();
      const beforeCount = this.list.children('li').length;
      this.list.append(data);
      this.isFetching = false;

      if(this.list.children('li').length - beforeCount < this.per_page) {
        console.log("Last page");
        this.lastPage = true;
      }
    });
  }
}
