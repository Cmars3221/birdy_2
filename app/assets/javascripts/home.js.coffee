# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# //= require ./flappy_bird_reborn/main

init = ->
  Game.setup()

$(document).ready(init)
$(document).on('page:load', init) # XXX - turbo-links prevents jQuery from working
