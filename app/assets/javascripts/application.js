// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require jquery.timepicker.js
//= require Datepair
//= require jquery.datepair.js
//= require bootstrap-datepicker
//= require bootstrap
//= require moment
//= require moment-timezone-with-data
//= require_tree .

jQuery(document).on('turbolinks:load', function() {
  $(".dropdown-toggle").dropdown();

  if ($('#subjects-list').length > 0) {
    $('#subjects-list').on('click', '.glyphicon-chevron-down', (e) => {
      $(e.target).toggleClass('glyphicon-chevron-down glyphicon-chevron-up');
    });

    $('#subjects-list').on('click', '.glyphicon-chevron-up', (e) => {
      $(e.target).toggleClass('glyphicon-chevron-up glyphicon-chevron-down');
    });
  }
});
