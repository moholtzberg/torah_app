jQuery(document).on('turbolinks:load', () => {
  if($('#lessons-list').length > 0) {
    const getData = (page) => ({
      page: page,
      search: {
      },
      filters: {
      }
    });

    new InfinityList({
      selector: "#lessons-list",
      url: `/users/id/lessons/fetch`,
      getData: getData,
      per_page: 10
    });
  }

  if($('#new_lesson').length > 0) {
    extendMoment(moment);
    const subjectPicker = createSubjectPicker('#lesson_subject_id');
    const userAvailability = getUserAvailability();

    function getDisabledTimeRanges(date) {
      const ranges = getUserUnavailability(date).map((el)=> {
        const start = el.start.utc();
        const end = el.end.utc();
        if (end.isAfter(start) && end.format("HH:mm") == "00:00") {
          return [start.format("HH:mm"), "24:00"]
        } else {
          return [start.format("HH:mm"), end.format("HH:mm")]
        }
      });
      return ranges;
    }

    function addRangesArray(array) {
      let result = [array[0]];
      array.forEach((el, i) => {
        if (i < array.length - 1) {
          const tempo = result.pop();
          const a = array[i+1];
          if (tempo.overlaps(a)) {
            result = result.concat(tempo.add(array[i+1]));
          } else {
            result = result.concat([tempo, a])
          }
        }
      });
      return result;
    }

    function getUserAvailability() {
      const availability = $('#user-availability').data('availability').map((e) => {
        const r = e.split('..');
        return moment.range(new Date(r[0]), new Date(r[1]));
      })
      return addRangesArray(availability);
    }

    function getUserUnavailability(date) {
      const start  = moment(new Date(date + 'T00:00:00'));
      const end = moment(new Date(date + 'T24:00:00'));
      const range = [moment.range(toAvailabilityWeek(start), toAvailabilityWeek(end))]
      return subtractRangesArray(range, userAvailability);
    }

    function toAvailabilityWeek(date) {
      return moment(`1996-01-01T${date.utc().format("HH:mm")}`).add(date.day() - 1,'days');
    }

    function rangeArrayContains(array, range) {
      array.forEach((el) => {
        if(el.isEqual(range)) {
          return true;
        }
      });
    }

    function subtractRangesArray(range, array) {
      let result = [];
      range.forEach((min) => {
          const diff = min.subtract(array[0]);
          result = result.concat(diff);
      });

      if(array.length == 1) {
        return result;
      } else {
        return subtractRangesArray(result, array.slice(1, array.length));
      }
    }
    /*
    function subtractRangesArray(range, array) {
      let result = [];
      range.forEach((min) => {
        array.forEach((sub)=> {
          const diff = min.subtract(sub);
          diff.forEach((el) => {
            if (!rangeArrayContains(result, el)) {
              result.push(el);
            }
          });
        });
      });

      if(result.length == range.length) {
        console.log("end");
        return result;
      } else {
        console.log(result.length);
        return subtractRangesArray(result, array);
      }
    }
    */

    function changeTimeRanges() {
      const endDate   = $('.lesson .date.end').val();
      const startDate = $('.lesson .date.start').val();
      $('.lesson .time.start').timepicker('option', 'disableTimeRanges', getDisabledTimeRanges(startDate));
      $('.lesson .time.end').timepicker('option', 'disableTimeRanges', getDisabledTimeRanges(endDate));
    }

    function checkCurrentUserAvailability() {
      $('#user-available').hide();
      $('#user-unavailable').hide();
      $('#check-user-availability-loader').show();
      $('input[type="submit"]').prop('disabled', true);

      $.get('/lessons/check_if_current_user_is_available', {
        starts_at_date: $('#lesson_starts_at_date').val(),
        ends_at_date:   $('#lesson_ends_at_date').val(),
        starts_at_time: $('#lesson_starts_at_time').val(),
        ends_at_time:   $('#lesson_ends_at_time').val()
      })
        .then((response) => {
          $('#check-user-availability-loader').hide();
          $('#user-available').show();
          $('input[type="submit"]').prop('disabled', false);
        })
        .fail((errors) => {
          $('input[type="submit"]').prop('disabled', false);
          $('#check-user-availability-loader').hide();
          $('#user-unavailable').show();
        })
    }

    const timepickerConfig = {
      showDuration: true,
      timeFormat: 'H:i'
    }

    $('.lesson .time.start').timepicker(timepickerConfig);
    $('.lesson .time.end').timepicker(timepickerConfig);

    $('.lesson .time').each((i, input) => {
      if (!input.value) {
        $(input).timepicker('setTime', new Date);
      }
    });


    $('input.date').datepicker({
        format: 'yyyy-mm-dd',
        autoclose: true,
        startDate: '-0d',
        todayHighlight: true,
    });

    $('.lesson .date').each((i, input) => {
      if (!input.value) {
        $(input).datepicker('setDate', new Date);;
      }
    });

    $('.day').datepair();
    $('.lesson').datepair();
    changeTimeRanges();
    $('.lesson .date').on('change', changeTimeRanges);


    $('.lesson .date').on('change', checkCurrentUserAvailability);
    $('.lesson .time').on('change', checkCurrentUserAvailability);
  }
});
