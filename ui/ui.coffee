# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>

apiType = 'admin'

### content functions ###

loadHome = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-home').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-dashboard').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html result.version

  fetchData "/api/v1/admin/changelog", (err, result) ->
    unless err
      $('.jido-data-changelog').html result

  fetchData "/api/v1/admin/settings", (err, result) ->
    unless err
      networkSettings = for key, value of result.network
        key = "IP address" if key == 'ip_address'
        key = "DNS 1" if key == 'dns1'
        key = "DNS 2" if key == 'dns2'

        "<li class=\"list-group-item\">#{capitalize key} <span class=\"pull-right text-primary\">#{value}</span></li>"

      $('.jido-data-network-info').html networkSettings

loadUpdateCerts = (msg) ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $("#jido-button-#{msg}").addClass('active')
  $('#jido-page-navbar').show()
  $(".jido-page-content-#{msg}").show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html result.version

  getStatus msg, (status) ->
    if status is "running"
      pollStatus msg

loadNetwork = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-network').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-network').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html result.version

  fetchData "/api/v1/admin/settings", (err, result) ->
    unless err
      $('.network-form input.form-control').val '' # reset all network input fields

      unless result.network.interface?
        $('#interface-input').val 'eth0'

      networkSettings = for key, value of result.network
        $("##{key}-input").val value

        key = "IP address" if key == 'ip_address'
        key = "DNS 1" if key == 'dns1'
        key = "DNS 2" if key == 'dns2'

        "<li class=\"list-group-item\">#{capitalize key} <span class=\"pull-right label label-primary\">#{value}</span></li>"

      $('.jido-data-network-info').html networkSettings

loadSupport = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-support').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-support').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html result.version

### onclick listeners ###

updateButtonListener = ->
  $('#jido-button-update-upload').click ->
    formData = new FormData()
    formData.append 'update', $('#update-input[type=file]')[0].files[0]

    if formData
      putFile 'update', "/api/v1/admin/update", formData, (err, result) ->
        unless err
          pollStatus 'update'

networkButtonListener = ->
  $('#jido-button-network-upload').click ->

    json = new Object()
    json.app = {}
    json.network = {}
    json.network.hostname = $('#hostname-input').val()
    json.network.interface = $('#interface-input').val()
    json.network.ip_address = $('#ip_address-input').val()
    json.network.netmask = $('#netmask-input').val()
    json.network.gateway = $('#gateway-input').val()
    if $('#dns1-input').val() then json.network.dns1 = $('#dns1-input').val()
    if $('#dns2-input').val() then json.network.dns2 = $('#dns2-input').val()

    # Validations
    unless json.network.hostname and validator.isFQDN(json.network.hostname, {require_tld: false})
      $('.network-form .network-hostname-label').parent().addClass 'has-error'
      $('.network-form .network-hostname-label').html 'Hostname (required)'
      $('.network-form .network-hostname-label').focus()
      return

    unless json.network.interface and validator.isAlphanumeric(json.network.interface)
      $('.network-form .network-interface-label').parent().addClass 'has-error'
      $('.network-form .network-interface-label').html 'Interface (required)'
      $('.network-form .network-interface-label').focus()
      return

    $('.jido-data-network-status').removeClass 'label-danger'
    $('.jido-data-network-status').removeClass 'label-success'
    $('.jido-data-network-status').removeClass 'label-default'

    if json.network.ip_address and json.network.netmask and json.network.gateway
      unless validator.isIP(json.network.ip_address)
        $('.network-form .network-ip_address-label').parent().addClass 'has-error'
        $('.network-form .network-ip_address-label').focus()
        return

      unless validator.isIP(json.network.netmask)
        unless validator.isInt(json.network.netmask.replace('/',''), { min: 1, max: 128 })
          $('.network-form .network-netmask-label').parent().addClass 'has-error'
          $('.network-form .network-netmask-label').focus()
          return

      unless validator.isIP(json.network.gateway)
        $('.network-form .network-gateway-label').parent().addClass 'has-error'
        $('.network-form .network-gateway-label').focus()
        return

      unless validator.isIP(json.network.dns1)
        $('.network-form .network-dns1-label').parent().addClass 'has-error'
        $('.network-form .network-dns1-label').focus()
        return

      unless validator.isIP(json.network.dns2)
        $('.network-form .network-dns2-label').parent().addClass 'has-error'
        $('.network-form .network-dns2-label').focus()
        return

      $('.jido-data-network-status').html 'STATIC'
      $('.jido-data-network-status').addClass 'label-success'
    else
      $('.jido-data-network-status').html 'DHCP'
      $('.jido-data-network-status').addClass 'label-success'
      delete json.network.ip_address
      delete json.network.netmask
      delete json.network.gateway
      delete json.network.dns1
      delete json.network.dns2

    formData = new FormData()
    encoded = JSON.stringify json
    blob = new Blob [encoded], {type: 'application/json'}
    blob.lastModifiedDate = new Date()

    formData.append 'settings', blob, 'settings.json'

    if formData
      putFile 'network', '/api/v1/admin/settings', formData, (err, result) ->
        unless err
          successUpload 'network'

          if json.network.ip_address
            newIP = if validator.isIP(json.network.ip_address, 4) then json.network.ip_address else "[#{json.network.ip_address}]"
            newUrl = "#{window.location.protocol}//#{newIP}#{(if window.location.port? then ':' + window.location.port else '')}"
            $(".network-alert").html "Redirecting to <a href=\"#{newUrl}\">#{newUrl}</a> in 5 seconds"
            $(".network-alert").show()
            redirectUrl newUrl
          else
            loadNetwork()

certsButtonListener = ->
  $('#jido-button-certs-upload').click ->
    formData = new FormData()
    formData.append 'public', $('#public-key-input[type=file]')[0].files[0]
    formData.append 'private', $('#private-key-input[type=file]')[0].files[0]
    formData.append 'ca', $('#ca-key-input[type=file]')[0].files[0] if $('#ca-key-input[type=file]')[0].files[0]

    if formData
      putFile 'certs', "/api/v1/admin/certs", formData, (err, result) ->
        unless err
          pollStatus 'certs'

updateCertsButtonListener = (msg) ->
  $("#jido-button-#{msg}-fulllog").click ->
    fetchData "/api/v1/admin/#{msg}/log", (err, result) ->
      unless err
        $("#jido-button-#{msg}-fulllog").addClass 'active'
        $(".jido-data-#{msg}-full-log").parent().show()
        $(".jido-data-#{msg}-full-log").html(if result then result else "No log file found")

logsButtonListener = ->
  $('#jido-data-logs-files').click ->
    fetchFile "/api/v1/admin/logs", (err) ->
      unless err
        return

debugButtonListener = ->
  $('#jido-data-debug-files').click ->
    fetchFile "/api/v1/admin/debug", (err) ->
      unless err
        return

restartButtonListener = ->
  $('#jido-button-restart-confirm').click ->
    fetchData "/api/v1/admin/reboot", (err) ->
      unless err
        $(".restart-alert").show()
        return

navbarListener = ->
  $('#jido-page-navbar .navbar-nav li a').click ->
    clicked = $(this).parent().attr 'id'
    switch clicked
      when "jido-button-home"     then loadHome()
      when "jido-button-update"   then loadUpdateCerts 'update'
      when "jido-button-network"  then loadNetwork()
      when "jido-button-certs"    then loadUpdateCerts 'certs'
      when "jido-button-license"  then loadLicense()
      when "jido-button-token"    then loadToken()
      when "jido-button-support"  then loadSupport()

### start here ###

updateButtonListener()
networkButtonListener()
certsButtonListener()
updateCertsButtonListener 'update'
# updateCertsButtonListener 'certs' # not used for now (endpoint doesn't exist)
logsButtonListener()
debugButtonListener()
restartButtonListener()
navbarListener()

authenticate (err) ->
  if err then loadLogin() else loadHome()
