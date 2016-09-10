# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>

'use strict'
apiServer = if window.location.origin?
  window.location.origin
else
  "#{window.location.protocol}//#{window.location.hostname}#{(if window.location.port? then ':' + window.location.port else '')}"

### generic functions ###

putToken = (sha256) ->
  if $('#login-remember').is(':checked')
    date    = new Date()
    oneDay  = (24 * 60 * 60 * 1000)
    days    = 30
    date.setTime(+ date + (days * oneDay))

    document.cookie = "jidoteki-admin-api-token=#{sha256}; expires=#{date.toGMTString()}; path=/"
  else
    document.cookie = "jidoteki-admin-api-token=#{sha256}; path=/"

getToken = ->
  (document.cookie.match('(^|; )jidoteki-admin-api-token=([^;]*)')||0)[2]

clearToken = ->
  document.cookie = 'jidoteki-admin-api-token=;'

capitalize = (string) ->
  string.charAt(0).toUpperCase() + string.slice(1)

getSha256 = (string) ->
  md = forge.md.sha256.create()
  md.update string

  md.digest().toHex()

getHmac = (string, key) ->
  hmac = forge.hmac.create()
  hmac.start 'sha256', key
  hmac.update string
  
  hmac.digest().toHex()

fetchData = (endpoint, callback) ->
  sha256 = getToken()
  if sha256?
    hmac = getHmac "GET#{endpoint}", sha256

    $.get "#{apiServer}#{endpoint}?hash=#{hmac}"

    .done (response) ->
      callback null, response

    .fail (err) ->
      callback new Error err
  else
    callback new Error "Missing or invalid API token"

fetchFile = (endpoint, callback) ->
  sha256 = getToken()
  if sha256?
    hmac = getHmac "GET#{endpoint}", sha256
    $(location).attr 'href', "#{apiServer}#{endpoint}?hash=#{hmac}"
  else
    callback new Error "Missing or invalid API token"

putFile = (msg, endpoint, file, callback) ->
  sha256 = getToken()
  if sha256?
    hmac = getHmac "POST#{endpoint}", sha256

    $(".jido-page-content-#{msg} .progress .progress-bar").removeClass 'progress-bar-danger'
    $(".jido-page-content-#{msg} .progress .progress-bar").removeClass 'progress-bar-primary'
    $(".jido-page-content-#{msg} .progress .progress-bar").addClass 'progress-bar-striped'
    $(".jido-page-content-#{msg} .progress .progress-bar").attr 'progress-bar-striped', 33
    $(".jido-page-content-#{msg} .progress .progress-bar").attr 'aria-valuenow', 33
    $(".jido-page-content-#{msg} .progress .progress-bar").html '....uploading, please wait'
    $(".jido-page-content-#{msg} .progress .progress-bar").attr 'style', 'width: 33%'
    $(".jido-page-content-#{msg} .progress").show()

    $.ajax
      url : "#{apiServer}#{endpoint}?hash=#{hmac}"
      type: "POST"
      data : file
      processData: false
      contentType: false
      success: (response, status, jqXHR) ->
        runningUpload msg
        callback null, response
      error: (jqXHR, status, err) ->
        failedUpload msg, 'upload failed'
        callback new Error err
  else
    callback new Error "Missing or invalid API token"

runningUpload = (msg) ->
  $(".jido-page-content-#{msg} .progress").show()
  $(".jido-page-content-#{msg} .progress .progress-bar").addClass 'progress-bar-primary'
  $(".jido-page-content-#{msg} .progress .progress-bar").attr 'progress-bar-striped', 66
  $(".jido-page-content-#{msg} .progress .progress-bar").attr 'aria-valuenow', 66
  $(".jido-page-content-#{msg} .progress .progress-bar").html '...updating'
  $(".jido-page-content-#{msg} .progress .progress-bar").attr 'style', 'width: 66%'

successUpload = (msg) ->
  $(".jido-page-content-#{msg} .progress .progress-bar").removeClass 'progress-bar-striped'
  $(".jido-page-content-#{msg} .progress .progress-bar").addClass 'progress-bar-success'
  $(".jido-page-content-#{msg} .progress .progress-bar").attr 'aria-valuenow', 100
  $(".jido-page-content-#{msg} .progress .progress-bar").html 'done'
  $(".jido-page-content-#{msg} .progress .progress-bar").attr 'style', 'width: 100%'

failedUpload = (msg, message) ->
  $(".jido-page-content-#{msg} .progress .progress-bar").removeClass 'progress-bar-striped'
  $(".jido-page-content-#{msg} .progress .progress-bar").addClass 'progress-bar-danger'
  $(".jido-page-content-#{msg} .progress .progress-bar").attr 'aria-valuenow', 100
  $(".jido-page-content-#{msg} .progress .progress-bar").html message
  $(".jido-page-content-#{msg} .progress .progress-bar").attr 'style', 'width: 100%'
  $(".#{msg}-form").show()
  $(".#{msg}-alert").hide()

getStatus = (msg, callback) ->
  fetchData "/api/v1/#{apiType}/#{msg}", (err, result) ->
    unless err
      $(".jido-data-#{msg}-status").html result.status
      $(".jido-data-#{msg}-log").html(if typeof result.log is 'object' then "No log file found" else result.log.replace(/\\n/g,'<br/>'))

      label = switch result.status
        when "failed"     then "label-danger"
        when "success"    then "label-success"
        when "running"    then "label-primary"
        else
          $(".jido-data-#{msg}-status").html "waiting for #{msg}"
          "label-default"

      $(".jido-data-#{msg}-status").removeClass("label-danger")
      $(".jido-data-#{msg}-status").removeClass("label-success")
      $(".jido-data-#{msg}-status").removeClass("label-default")
      $(".jido-data-#{msg}-status").addClass(label)

      callback result.status

pollStatus = (msg) ->
  $(".#{msg}-form").hide()
  $(".#{msg}-alert").show()

  interval = setInterval () ->
    getStatus msg, (status) ->
      if status is "failed"
        clearInterval interval
        failedUpload msg, 'failed'
      else if status is "success"
        clearInterval interval
        successUpload msg
      else if status is "running"
        runningUpload msg
  , 1000

redirectUrl = (newUrl) ->
  interval = setInterval () ->
    clearInterval interval
    $(location).attr 'href', newUrl
  , 5000

authenticate = (callback) ->
  fetchData "/api/v1/admin/version", (err, result) ->
    if err
      clearToken()
      callback err
    else
      callback null

### generic content functions ###

loadToken = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-token').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-token').show()
  $('.jido-page-content-token .jido-panel-network').show()
  $('.token-form .token-token1-label').focus()
  $('.token-form input.form-control').val '' # reset all token input fields

loadSetup = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar').hide()
  $('#jido-page-token').show()
  $('.jido-page-content-token .jido-panel-network').show()
  $('.token-form .token-token1-label').focus()

  $('.token-form input.form-control').val '' # reset all token input fields

loadLogin = ->
  $('.jido-page-content').hide()
  $('#jido-page-navbar').hide()
  $('#jido-page-login').show()
  $('#login-password').focus()

### generic onclick listeners ###

logoutButtonListener = ->
  $('#jido-button-logout').click ->
    clearToken()
    loadLogin()

loginButtonListener = ->
  $('#jido-button-login').click ->
    pass = $('#login-password').val()
    sha256 = getSha256 pass if pass.length >= 8 && pass.length <= 64
    if sha256?
      putToken sha256
      authenticate (err) ->
        if err
          $('#invalid-token').show()
          $('#login-password').focus()
        else
          $('#login-password').val ''
          $('#invalid-token').hide()
          loadHome()
    else
      $('#invalid-token').show()
      $('#login-password').focus()

newTokenButtonListener = ->
  $('#new-token').click ->
    loadSetup()

tokenButtonListener = ->
  $('#jido-button-token-upload').click ->
    pass1 = $('#token1-input').val()
    pass2 = $('#token2-input').val()

    unless pass1
      $('.token-form .token-token1-label').parent().addClass 'has-error'
      $('.token-form .token-token1-label').html 'API Token (required)'
      $('.token-form .token-token1-label').focus()
      return

    unless pass2
      $('.token-form .token-token2-label').parent().addClass 'has-error'
      $('.token-form .token-token2-label').html 'Confirm API Token (required)'
      $('.token-form .token-token2-label').focus()
      return

    unless pass1 is pass2
      $('.token-alert').html 'API Token mismatch. Please verify the API Token.'
      $(".token-alert").show()
      return

    sha256 = getSha256 pass1 if pass1.length >= 8 && pass1.length <= 64
    unless sha256?
      $(".token-alert").html 'Invalid API Token. Must be between 8 and 64 characters'
      $(".token-alert").show()
      $('.token-form .token-token1-label').parent().addClass 'has-error'
      $('.token-form .token-token1-label').html 'API Token (required)'
      $('.token-form .token-token2-label').parent().addClass 'has-error'
      $('.token-form .token-token2-label').html 'Confirm API Token (required)'
      $('.token-form .token-token1-label').focus()
      return

    formData = new FormData()
    formData.append 'newtoken', pass1

    if formData
      putFile 'token', '/api/v1/admin/setup', formData, (err, result) ->
        if err
          $('.jido-data-token-status').html 'failed'
          $('.jido-data-token-status').removeClass 'label-danger'
          $('.jido-data-token-status').removeClass 'label-success'
          $('.jido-data-token-status').removeClass 'label-default'
          $('.jido-data-token-status').addClass 'label-danger'

          failedUpload 'token'
        else
          $('.jido-data-token-status').html 'changed'
          $('.jido-data-token-status').removeClass 'label-danger'
          $('.jido-data-token-status').removeClass 'label-success'
          $('.jido-data-token-status').removeClass 'label-default'
          $('.jido-data-token-status').addClass 'label-success'
          $(".token-alert").hide()

          putToken sha256
          successUpload 'token'
          $('#token1-input').val ''
          $('#token2-input').val ''
          $('.jido-page-content-token .jido-panel-network').hide()
          loadToken()

### generic start here ###

logoutButtonListener()
loginButtonListener()
newTokenButtonListener()
tokenButtonListener()
