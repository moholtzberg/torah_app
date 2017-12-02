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

    const subjectPicker = createSubjectPicker('#lesson_subject_id');

    const timeZone = moment.tz.names().find((zone) => zone.includes($('#timezone').data('timezone')));

    function getDisabledTimeRangesForStart(date) {
      return unavailabilityTimeOnStart(date).concat(lessonsTimeOnStart(date))
    }

    function getDisabledTimeRangesForEnd(date) {
      return unavailabilityTimeOnEnd(date).concat(lessonsTimeOnEnd(date))
    }

    function unavailabilityTimeOnEnd(date) {
      const availability = userAvailability().concat(currentUserAvailability()).filter((e) => {
        return e[1].day == date.day
      })

      let result = []

      availability.forEach((e) => {
        if (e[0] == e[1]) {
          result.push(["00:00", e[0].format('kk:mm')])
        }
        result.push([e[1].format('kk:mm'), "24:00"])
      });

      return result;
    }

    function unavailabilityTimeOnStart(date) {
      const availability = userAvailability().concat(currentUserAvailability()).filter((e) => {
        return e[0].day == date.day
      })

      let result = []

      availability.forEach((e) => {
        if (e[0] == e[1]) {
          result.push([e[1].format('kk:mm'), "24:00"])
        }
        result.push(["00:00", e[0].format('kk:mm')])
      })

      return result;
    }


    function userAvailability() {
      return $('#user-availability').data('availability').map((e) => {
        const a = e.split('..');
        return [moment(new Date(a[0])).tz(timeZone), moment(new Date(a[1])).tz(timeZone)];
      })
    }

    function currentUserAvailability() {
      return $('#current-user-availability').data('availability').map((e) => {
        const a = e.split('..');
        return [moment(new Date(a[0])).tz(timeZone), moment(new Date(a[1])).tz(timeZone)];
      })
    }

    function lessonsTime(date) {
      const lessons = ($('#lessons-time').data('lessons')).map((l) => {
        let time = l['time'].split('..');
        return [moment(new Date(time[0])).tz(timeZone), moment(new Date(time[1])).tz(timeZone), l["recurring"]]
      });
      return lessons;
    }

    function lessonsTimeOnStart(date) {
      const lessons = lessonsTime(date).filter((l) => {
        return l[0] == date ||
               (l[0].day == date.day && l[2])
      })

      return lessons? lessons.map((l) => {
        if (l[0] == l[1]) {
          return [l[0].format('kk:mm'),
                 l[1].format('kk:mm')]
        }
        return [
        l[0].format('kk:mm'),
        "24:00"
      ]}) : []
    }

    function lessonsTimeOnEnd(date) {
      const lessons = lessonsTime(date).filter((l) => {
        return l[1] == date ||
               (l[1].day == date.day && l[2])
      })

      return lessons? lessons.map((l) => {
        if (l[0] == l[1]) {
          return [l[0].format('kk:mm'),
                 l[1].format('kk:mm')]
        }
        return [
        "00:00",
        l[1].format('kk:mm')
      ]}) : []
    }

    function changeTimeRanges() {
      const endDate = moment(new Date($('.lesson .date.end').val())).tz(timeZone)
      const startDate = moment(new Date($('.lesson .date.start').val())).tz(timeZone)
      $('.lesson .time.start').timepicker('option', 'disableTimeRanges', getDisabledTimeRangesForStart(startDate));
      $('.lesson .time.end').timepicker('option', 'disabTZTimeRanges', getDisabledTimeRangesForEnd(endDate));
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

    $('.lesson .time.start').timepicker({
      showDuration: true,
      timeFormat: 'H:i',
      disableTimeRanges: getDisabledTimeRangesForStart(moment(new Date).tz(timeZone))
    });

    $('.lesson .time.end').timepicker({
      showDuration: true,
      timeFormat: 'H:i',
      disableTimeRanges: getDisabledTimeRangesForEnd(moment(new Date).tz(timeZone))
    });

    $('.lesson .time').timepicker('setTime', new Date);

    $('input.date').datepicker({
        format: 'yyyy-m-d',
        autoclose: true,
        startDate: '-0d',
        todayHighlight: true
    });

    $('.lesson .date').datepicker('setDate', new Date);

    $('.day').datepair();
    $('.lesson').datepair();
    $('.lesson .date').on('change', changeTimeRanges);

    $('.lesson .date').on('change', checkCurrentUserAvailability);
    $('.lesson .time').on('change', checkCurrentUserAvailability);
  }
});
