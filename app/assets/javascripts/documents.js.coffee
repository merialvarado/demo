# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  $("#sortable").sortable
    axis: 'y',
    opacity: 0.4,
    handle: '.handle'
    update: ->
      $.post('/sections/sort.html', $(this).sortable('serialize'))