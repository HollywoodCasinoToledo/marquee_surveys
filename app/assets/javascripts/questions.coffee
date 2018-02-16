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

  $('.single_answer').on('click', ->
    checked = $(this).find("input")
    question = $(this).data("question_id")
    $("[data-question_id=" + question + "]").find("input").val(0)
    $("[data-question_id=" + question + "]").find("input").prop('checked', false)
    $("[data-question_id=" + question + "]").removeClass 'selected'
    checked.val(1)
    checked.prop('checked', true)
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
    question = $(this).data("question_id")
    if checked.val() == '1'
      checked.val(0)
      checked.prop('checked', false)
    else
      checked.val(1)
      checked.prop('checked', true)
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

  $('#question_next_id').on('change', ->
    selected = $('#question_next_id :selected').val()
    if selected != "move_to_end"
      $('#question_operation').val('move')
    else
      $('#question_operation').val('move_to_end')
    return
  )

  $('.question').on('click', ->
    $('.dd-handle.answer[data-question=' + $(this).data("id") + ']').parent().toggleClass("hidden")
    return
  )

  $('.dd-item').on('mouseover', ->
    $(this).find(".list-group-controls").removeClass('hidden')
    return
  )

  $('.dd-item').on('mouseout', ->
    $(this).find(".list-group-controls").addClass('hidden')
    return
  )

  $(".confirm-image").animate({
        fontSize: '+=150px',
        marginTop: '+=200px'
    });
  $(".confirm-message").animate({
        opacity: '+=1'
    });
  $(".confirm-button").animate({
        opacity: '+=1'
    });


  return