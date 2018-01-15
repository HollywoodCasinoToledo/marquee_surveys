# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  style = $('#style').val()
  if style != ''
    $('.question_style_button').removeClass('btn-primary')
    idz = '#' + style
    $(idz).addClass('btn-primary')

  $('.question_style_button').on 'click', (e) ->
    e.preventDefault()
    $('.question_style_button').removeClass('btn-primary')
    $(this).addClass('btn-primary')
    $('#style').val($(this).attr('id'))
    return

  $('#star_rankings div').on('mouseover', ->
    onStar = parseInt($(this).children('div.star-ranks').data('rate'), 10)
    $('#star_rankings div').children('div.star-ranks').each (e) ->
      e = $(this).data('rate')
      if e <= onStar
        $(this).addClass 'selected'
      else
        $(this).removeClass 'selected'
      return
    return
  ).on('click', ->
    $(this).parent().children('div.star-ranks').each (e) ->
      $('#answer_id').val($(this).data('answer_id'))
      $('#answer_rate').val($(this).data('rate'))
      return
    return
  ).on('mouseout', ->
    $('#star_rankings div').children('div.star-ranks').each (e) ->
      selectedStar = $('#answer_rate').val()
      if e < selectedStar
        $(this).addClass 'selected'
      else
        $(this).removeClass 'selected'
      return
    return
  )

  $('.star-ranks').on('click', ->
    checked = $(this).parent().find("input")
    $('.star-rank-holder').find('input').val(0)
    checked.val(1)
    return
  )

  $('.single_answer').on('click', ->
    checked = $(this).find("input")
    $('.single_answer').find("input").val(0)
    checked.val(1)
    $('.single_answer').each (e) ->
      $(this).removeClass 'selected'
      return
    $(this).addClass 'selected'
    return
  )

  $(document).ready ->
    stripped_url = document.location.toString().split("#")  
    if (stripped_url.length > 1)
      target_id = stripped_url[1]
      $('#' + target_id).addClass('selected-border')
      return
    $('.selected').find("input").val(1)
    return
   
  $('.multiple_answers').on('click', ->
    checked = $(this).find("input")
    if checked.val() == '1'
      checked.val(0)
    else
      checked.val(1)
    $(this).toggleClass 'selected'
    return
  )

  $('.bool_button').on('click', ->
    checked = $(this).find("input")
    $('.bool_button').find("input").val(0)
    checked.val(1)
    $('.bool_button').each (e) ->
      $(this).find(".btn").removeClass 'btn-primary'
      $(this).find(".btn").addClass 'btn-default'
      return
    $(this).find(".btn").removeClass 'btn-default'
    $(this).find(".btn").addClass 'btn-primary'
    return
  )

  $('#question_parent').on('change', ->
    $('#required_question').text($('#question_parent :selected').parent().attr('label'))
    return
  )

  $('#question_next_id').on('change', ->
    $('#question_next').text($('#question_next :selected').parent().attr('label'))
    return
  )

  $('.direct-fade').on('click', ->
    $(target_id).addClass('selected-fade')
    $(target_id).removeClass('selected-fade')
    return
  )

  $('.question').on('click', ->
    $('.list-group-item.answer[data-question=' + $(this).data("id") + ']').toggleClass("hidden")
    return
  )

  $('.list-group-item').on('mouseover', ->
    $(this).find(".list-group-controls").removeClass('hidden')
    return
  )

  $('.list-group-item').on('mouseout', ->
    $(this).find(".list-group-controls").addClass('hidden')
    return
  )


  return