
/*
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

  Copyright (c) 2015-2016 Alexander Williams, Unscramble <license@unscramble.jp>
 */

(function() {
  'use strict';
  var apiServer, authenticate, capitalize, certsButtonListener, clearToken, debugButtonListener, failedUpload, fetchData, fetchFile, getHmac, getSha256, getStatus, getToken, loadHome, loadLogin, loadNetwork, loadSetup, loadSupport, loadToken, loadUpdateCerts, loginButtonListener, logoutButtonListener, logsButtonListener, navbarListener, networkButtonListener, newTokenButtonListener, pollStatus, putData, putFile, putToken, redirectUrl, restartButtonListener, runningUpload, successUpload, tokenButtonListener, updateButtonListener, updateCertsButtonListener;

  apiServer = window.location.origin != null ? window.location.origin : window.location.protocol + "//" + window.location.hostname + (window.location.port != null ? ':' + window.location.port : '');


  /* generic functions */

  putToken = function(sha256) {
    var date, days, oneDay;
    if ($('#login-remember').is(':checked')) {
      date = new Date();
      oneDay = 24 * 60 * 60 * 1000;
      days = 30;
      date.setTime(+date + (days * oneDay));
      return document.cookie = "jidoteki-admin-api-token=" + sha256 + "; expires=" + (date.toGMTString()) + "; path=/";
    } else {
      return document.cookie = "jidoteki-admin-api-token=" + sha256 + "; path=/";
    }
  };

  getToken = function() {
    return (document.cookie.match('(^|; )jidoteki-admin-api-token=([^;]*)') || 0)[2];
  };

  clearToken = function() {
    return document.cookie = 'jidoteki-admin-api-token=;';
  };

  capitalize = function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  getSha256 = function(string) {
    var md;
    md = forge.md.sha256.create();
    md.update(string);
    return md.digest().toHex();
  };

  getHmac = function(string, key) {
    var hmac;
    hmac = forge.hmac.create();
    hmac.start('sha256', key);
    hmac.update(string);
    return hmac.digest().toHex();
  };

  fetchData = function(endpoint, callback) {
    var hmac, sha256;
    sha256 = getToken();
    if (sha256 != null) {
      hmac = getHmac("GET" + endpoint, sha256);
      return $.get("" + apiServer + endpoint + "?hash=" + hmac).done(function(response) {
        return callback(null, response);
      }).fail(function(err) {
        return callback(new Error(err));
      });
    } else {
      return callback(new Error("Missing or invalid API token"));
    }
  };

  fetchFile = function(endpoint, callback) {
    var hmac, sha256;
    sha256 = getToken();
    if (sha256 != null) {
      hmac = getHmac("GET" + endpoint, sha256);
      return $(location).attr('href', "" + apiServer + endpoint + "?hash=" + hmac);
    } else {
      return callback(new Error("Missing or invalid API token"));
    }
  };

  putData = function(endpoint, data, callback) {
    var hmac, sha256;
    sha256 = getToken();
    if (sha256 != null) {
      hmac = getHmac("POST" + endpoint, sha256);
      return $.post("" + apiServer + endpoint + "?hash=" + hmac, data).done(function(response) {
        return callback(null, response);
      }).fail(function(err) {
        return callback(new Error(err));
      });
    } else {
      return callback(new Error("Missing or invalid API token"));
    }
  };

  putFile = function(msg, endpoint, file, callback) {
    var hmac, sha256;
    sha256 = getToken();
    if (sha256 != null) {
      hmac = getHmac("POST" + endpoint, sha256);
      $(".jido-page-content-" + msg + " .progress .progress-bar").removeClass('progress-bar-danger');
      $(".jido-page-content-" + msg + " .progress .progress-bar").removeClass('progress-bar-primary');
      $(".jido-page-content-" + msg + " .progress .progress-bar").addClass('progress-bar-striped');
      $(".jido-page-content-" + msg + " .progress .progress-bar").attr('progress-bar-striped', 33);
      $(".jido-page-content-" + msg + " .progress .progress-bar").attr('aria-valuenow', 33);
      $(".jido-page-content-" + msg + " .progress .progress-bar").html('....uploading, please wait');
      $(".jido-page-content-" + msg + " .progress .progress-bar").attr('style', 'width: 33%');
      $(".jido-page-content-" + msg + " .progress").show();
      return $.ajax({
        url: "" + apiServer + endpoint + "?hash=" + hmac,
        type: "POST",
        data: file,
        processData: false,
        contentType: false,
        success: function(response, status, jqXHR) {
          runningUpload(msg);
          return callback(null, response);
        },
        error: function(jqXHR, status, err) {
          failedUpload(msg, 'upload failed');
          return callback(new Error(err));
        }
      });
    } else {
      return callback(new Error("Missing or invalid API token"));
    }
  };

  runningUpload = function(msg) {
    $(".jido-page-content-" + msg + " .progress").show();
    $(".jido-page-content-" + msg + " .progress .progress-bar").addClass('progress-bar-primary');
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('progress-bar-striped', 66);
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('aria-valuenow', 66);
    $(".jido-page-content-" + msg + " .progress .progress-bar").html('...updating');
    return $(".jido-page-content-" + msg + " .progress .progress-bar").attr('style', 'width: 66%');
  };

  successUpload = function(msg) {
    $(".jido-page-content-" + msg + " .progress .progress-bar").removeClass('progress-bar-striped');
    $(".jido-page-content-" + msg + " .progress .progress-bar").addClass('progress-bar-success');
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('aria-valuenow', 100);
    $(".jido-page-content-" + msg + " .progress .progress-bar").html('done');
    return $(".jido-page-content-" + msg + " .progress .progress-bar").attr('style', 'width: 100%');
  };

  failedUpload = function(msg, message) {
    $(".jido-page-content-" + msg + " .progress .progress-bar").removeClass('progress-bar-striped');
    $(".jido-page-content-" + msg + " .progress .progress-bar").addClass('progress-bar-danger');
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('aria-valuenow', 100);
    $(".jido-page-content-" + msg + " .progress .progress-bar").html(message);
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('style', 'width: 100%');
    $("." + msg + "-form").show();
    return $("." + msg + "-alert").hide();
  };

  getStatus = function(msg, callback) {
    return fetchData("/api/v1/admin/" + msg, function(err, result) {
      var label;
      if (!err) {
        $(".jido-data-" + msg + "-status").html(result.status);
        $(".jido-data-" + msg + "-log").html(typeof result.log === 'object' ? "No log file found" : result.log.replace(/\\n/g, '<br/>'));
        label = (function() {
          switch (result.status) {
            case "failed":
              return "label-danger";
            case "success":
              return "label-success";
            case "running":
              return "label-primary";
            default:
              $(".jido-data-" + msg + "-status").html("waiting for " + msg);
              return "label-default";
          }
        })();
        $(".jido-data-" + msg + "-status").removeClass("label-danger");
        $(".jido-data-" + msg + "-status").removeClass("label-success");
        $(".jido-data-" + msg + "-status").removeClass("label-default");
        $(".jido-data-" + msg + "-status").addClass(label);
        return callback(result.status);
      }
    });
  };

  pollStatus = function(msg) {
    var interval;
    $("." + msg + "-form").hide();
    $("." + msg + "-alert").show();
    return interval = setInterval(function() {
      return getStatus(msg, function(status) {
        if (status === "failed") {
          clearInterval(interval);
          return failedUpload(msg, 'failed');
        } else if (status === "success") {
          clearInterval(interval);
          return successUpload(msg);
        } else if (status === "running") {
          return runningUpload(msg);
        }
      });
    }, 1000);
  };

  redirectUrl = function(newUrl) {
    var interval;
    return interval = setInterval(function() {
      clearInterval(interval);
      return $(location).attr('href', newUrl);
    }, 5000);
  };

  authenticate = function(callback) {
    return fetchData("/api/v1/admin/version", function(err, result) {
      if (err) {
        clearToken();
        return callback(err);
      } else {
        return callback(null);
      }
    });
  };


  /* content functions */

  loadHome = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-home').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-dashboard').show();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(result.version);
      }
    });
    fetchData("/api/v1/admin/changelog", function(err, result) {
      if (!err) {
        return $('.jido-data-changelog').html(result);
      }
    });
    return fetchData("/api/v1/admin/settings", function(err, result) {
      var key, networkSettings, value;
      if (!err) {
        networkSettings = (function() {
          var ref, results;
          ref = result.network;
          results = [];
          for (key in ref) {
            value = ref[key];
            if (key === 'ip_address') {
              key = "IP address";
            }
            if (key === 'dns1') {
              key = "DNS 1";
            }
            if (key === 'dns2') {
              key = "DNS 2";
            }
            results.push("<li class=\"list-group-item\">" + (capitalize(key)) + " <span class=\"pull-right text-primary\">" + value + "</span></li>");
          }
          return results;
        })();
        return $('.jido-data-network-info').html(networkSettings);
      }
    });
  };

  loadUpdateCerts = function(msg) {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $("#jido-button-" + msg).addClass('active');
    $('#jido-page-navbar').show();
    $(".jido-page-content-" + msg).show();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(result.version);
      }
    });
    return getStatus(msg, function(status) {
      if (status === "running") {
        return pollStatus(msg);
      }
    });
  };

  loadNetwork = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-network').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-network').show();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(result.version);
      }
    });
    return fetchData("/api/v1/admin/settings", function(err, result) {
      var key, networkSettings, value;
      if (!err) {
        $('.network-form input.form-control').val('');
        if (result.network["interface"] == null) {
          $('#interface-input').val('eth0');
        }
        networkSettings = (function() {
          var ref, results;
          ref = result.network;
          results = [];
          for (key in ref) {
            value = ref[key];
            $("#" + key + "-input").val(value);
            if (key === 'ip_address') {
              key = "IP address";
            }
            if (key === 'dns1') {
              key = "DNS 1";
            }
            if (key === 'dns2') {
              key = "DNS 2";
            }
            results.push("<li class=\"list-group-item\">" + (capitalize(key)) + " <span class=\"pull-right label label-primary\">" + value + "</span></li>");
          }
          return results;
        })();
        return $('.jido-data-network-info').html(networkSettings);
      }
    });
  };

  loadToken = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-token').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-token').show();
    $('.jido-page-content-token .jido-panel-network').show();
    $('.token-form .token-token1-label').focus();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(result.version);
      }
    });
    return $('.token-form input.form-control').val('');
  };

  loadSetup = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar').hide();
    $('#jido-page-token').show();
    $('.jido-page-content-token .jido-panel-network').show();
    $('.token-form .token-token1-label').focus();
    return $('.token-form input.form-control').val('');
  };

  loadSupport = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-support').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-support').show();
    return fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(result.version);
      }
    });
  };

  loadLogin = function() {
    $('.jido-page-content').hide();
    $('#jido-page-navbar').hide();
    $('#jido-page-login').show();
    return $('#login-password').focus();
  };


  /* onclick listeners */

  logoutButtonListener = function() {
    return $('#jido-button-logout').click(function() {
      clearToken();
      return loadLogin();
    });
  };

  loginButtonListener = function() {
    return $('#jido-button-login').click(function() {
      var pass, sha256;
      pass = $('#login-password').val();
      if (pass.length >= 8 && pass.length <= 64) {
        sha256 = getSha256(pass);
      }
      if (sha256 != null) {
        putToken(sha256);
        return authenticate(function(err) {
          if (err) {
            $('#invalid-token').show();
            return $('#login-password').focus();
          } else {
            $('#login-password').val('');
            $('#invalid-token').hide();
            return loadHome();
          }
        });
      } else {
        $('#invalid-token').show();
        return $('#login-password').focus();
      }
    });
  };

  newTokenButtonListener = function() {
    return $('#new-token').click(function() {
      return loadSetup();
    });
  };

  updateButtonListener = function() {
    return $('#jido-button-update-upload').click(function() {
      var formData;
      formData = new FormData();
      formData.append('update', $('#update-input[type=file]')[0].files[0]);
      if (formData) {
        return putFile('update', "/api/v1/admin/update", formData, function(err, result) {
          if (!err) {
            return pollStatus('update');
          }
        });
      }
    });
  };

  networkButtonListener = function() {
    return $('#jido-button-network-upload').click(function() {
      var blob, encoded, formData, json;
      json = new Object();
      json.app = {};
      json.network = {};
      json.network.hostname = $('#hostname-input').val();
      json.network["interface"] = $('#interface-input').val();
      json.network.ip_address = $('#ip_address-input').val();
      json.network.netmask = $('#netmask-input').val();
      json.network.gateway = $('#gateway-input').val();
      if ($('#dns1-input').val()) {
        json.network.dns1 = $('#dns1-input').val();
      }
      if ($('#dns2-input').val()) {
        json.network.dns2 = $('#dns2-input').val();
      }
      if (!(json.network.hostname && validator.isFQDN(json.network.hostname, {
        require_tld: false
      }))) {
        $('.network-form .network-hostname-label').parent().addClass('has-error');
        $('.network-form .network-hostname-label').html('Hostname (required)');
        $('.network-form .network-hostname-label').focus();
        return;
      }
      if (!(json.network["interface"] && validator.isAlphanumeric(json.network["interface"]))) {
        $('.network-form .network-interface-label').parent().addClass('has-error');
        $('.network-form .network-interface-label').html('Interface (required)');
        $('.network-form .network-interface-label').focus();
        return;
      }
      $('.jido-data-network-status').removeClass('label-danger');
      $('.jido-data-network-status').removeClass('label-success');
      $('.jido-data-network-status').removeClass('label-default');
      if (json.network.ip_address && json.network.netmask && json.network.gateway) {
        if (!validator.isIP(json.network.ip_address)) {
          $('.network-form .network-ip_address-label').parent().addClass('has-error');
          $('.network-form .network-ip_address-label').focus();
          return;
        }
        if (!validator.isIP(json.network.netmask)) {
          if (!validator.isInt(json.network.netmask.replace('/', ''), {
            min: 1,
            max: 128
          })) {
            $('.network-form .network-netmask-label').parent().addClass('has-error');
            $('.network-form .network-netmask-label').focus();
            return;
          }
        }
        if (!validator.isIP(json.network.gateway)) {
          $('.network-form .network-gateway-label').parent().addClass('has-error');
          $('.network-form .network-gateway-label').focus();
          return;
        }
        if (!validator.isIP(json.network.dns1)) {
          $('.network-form .network-dns1-label').parent().addClass('has-error');
          $('.network-form .network-dns1-label').focus();
          return;
        }
        if (!validator.isIP(json.network.dns2)) {
          $('.network-form .network-dns2-label').parent().addClass('has-error');
          $('.network-form .network-dns2-label').focus();
          return;
        }
        $('.jido-data-network-status').html('STATIC');
        $('.jido-data-network-status').addClass('label-success');
      } else {
        $('.jido-data-network-status').html('DHCP');
        $('.jido-data-network-status').addClass('label-success');
        delete json.network.ip_address;
        delete json.network.netmask;
        delete json.network.gateway;
        delete json.network.dns1;
        delete json.network.dns2;
      }
      formData = new FormData();
      encoded = JSON.stringify(json);
      blob = new Blob([encoded], {
        type: 'application/json'
      });
      blob.lastModifiedDate = new Date();
      formData.append('settings', blob, 'settings.json');
      if (formData) {
        return putFile('network', '/api/v1/admin/settings', formData, function(err, result) {
          var newIP, newUrl;
          if (!err) {
            successUpload('network');
            if (json.network.ip_address) {
              newIP = validator.isIP(json.network.ip_address, 4) ? json.network.ip_address : "[" + json.network.ip_address + "]";
              newUrl = window.location.protocol + "//" + newIP + (window.location.port != null ? ':' + window.location.port : '');
              $(".network-alert").html("Redirecting to <a href=\"" + newUrl + "\">" + newUrl + "</a> in 5 seconds");
              $(".network-alert").show();
              return redirectUrl(newUrl);
            } else {
              return loadNetwork();
            }
          }
        });
      }
    });
  };

  certsButtonListener = function() {
    return $('#jido-button-certs-upload').click(function() {
      var formData;
      formData = new FormData();
      formData.append('public', $('#public-key-input[type=file]')[0].files[0]);
      formData.append('private', $('#private-key-input[type=file]')[0].files[0]);
      if ($('#ca-key-input[type=file]')[0].files[0]) {
        formData.append('ca', $('#ca-key-input[type=file]')[0].files[0]);
      }
      if (formData) {
        return putFile('certs', "/api/v1/admin/certs", formData, function(err, result) {
          if (!err) {
            return pollStatus('certs');
          }
        });
      }
    });
  };

  updateCertsButtonListener = function(msg) {
    return $("#jido-button-" + msg + "-fulllog").click(function() {
      return fetchData("/api/v1/admin/" + msg + "/log", function(err, result) {
        if (!err) {
          $("#jido-button-" + msg + "-fulllog").addClass('active');
          $(".jido-data-" + msg + "-full-log").parent().show();
          return $(".jido-data-" + msg + "-full-log").html(result ? result : "No log file found");
        }
      });
    });
  };

  tokenButtonListener = function() {
    return $('#jido-button-token-upload').click(function() {
      var formData, pass1, pass2, sha256;
      pass1 = $('#token1-input').val();
      pass2 = $('#token2-input').val();
      if (!pass1) {
        $('.token-form .token-token1-label').parent().addClass('has-error');
        $('.token-form .token-token1-label').html('API Token (required)');
        $('.token-form .token-token1-label').focus();
        return;
      }
      if (!pass2) {
        $('.token-form .token-token2-label').parent().addClass('has-error');
        $('.token-form .token-token2-label').html('Confirm API Token (required)');
        $('.token-form .token-token2-label').focus();
        return;
      }
      if (pass1 !== pass2) {
        $('.token-alert').html('API Token mismatch. Please verify the API Token.');
        $(".token-alert").show();
        return;
      }
      if (pass1.length >= 8 && pass1.length <= 64) {
        sha256 = getSha256(pass1);
      }
      if (sha256 == null) {
        $(".token-alert").html('Invalid API Token. Must be between 8 and 64 characters');
        $(".token-alert").show();
        $('.token-form .token-token1-label').parent().addClass('has-error');
        $('.token-form .token-token1-label').html('API Token (required)');
        $('.token-form .token-token2-label').parent().addClass('has-error');
        $('.token-form .token-token2-label').html('Confirm API Token (required)');
        $('.token-form .token-token1-label').focus();
        return;
      }
      formData = new FormData();
      formData.append('newtoken', pass1);
      if (formData) {
        return putFile('token', '/api/v1/admin/setup', formData, function(err, result) {
          if (err) {
            $('.jido-data-token-status').html('failed');
            $('.jido-data-token-status').removeClass('label-danger');
            $('.jido-data-token-status').removeClass('label-success');
            $('.jido-data-token-status').removeClass('label-default');
            $('.jido-data-token-status').addClass('label-danger');
            return failedUpload('token');
          } else {
            $('.jido-data-token-status').html('changed');
            $('.jido-data-token-status').removeClass('label-danger');
            $('.jido-data-token-status').removeClass('label-success');
            $('.jido-data-token-status').removeClass('label-default');
            $('.jido-data-token-status').addClass('label-success');
            $(".token-alert").hide();
            putToken(sha256);
            successUpload('token');
            $('#token1-input').val('');
            $('#token2-input').val('');
            $('.jido-page-content-token .jido-panel-network').hide();
            return loadToken();
          }
        });
      }
    });
  };

  logsButtonListener = function() {
    return $('#jido-data-logs-files').click(function() {
      return fetchFile("/api/v1/admin/logs", function(err) {
        if (!err) {

        }
      });
    });
  };

  debugButtonListener = function() {
    return $('#jido-data-debug-files').click(function() {
      return fetchFile("/api/v1/admin/debug", function(err) {
        if (!err) {

        }
      });
    });
  };

  restartButtonListener = function() {
    return $('#jido-button-restart-confirm').click(function() {
      return fetchData("/api/v1/admin/reboot", function(err) {
        if (!err) {
          $(".restart-alert").show();
        }
      });
    });
  };

  navbarListener = function() {
    return $('#jido-page-navbar .navbar-nav li a').click(function() {
      var clicked;
      clicked = $(this).parent().attr('id');
      switch (clicked) {
        case "jido-button-home":
          return loadHome();
        case "jido-button-update":
          return loadUpdateCerts('update');
        case "jido-button-network":
          return loadNetwork();
        case "jido-button-certs":
          return loadUpdateCerts('certs');
        case "jido-button-license":
          return loadLicense();
        case "jido-button-token":
          return loadToken();
        case "jido-button-support":
          return loadSupport();
      }
    });
  };


  /* start here */

  logoutButtonListener();

  loginButtonListener();

  newTokenButtonListener();

  updateButtonListener();

  networkButtonListener();

  certsButtonListener();

  tokenButtonListener();

  updateCertsButtonListener('update');

  logsButtonListener();

  debugButtonListener();

  restartButtonListener();

  navbarListener();

  authenticate(function(err) {
    if (err) {
      return loadLogin();
    } else {
      return loadHome();
    }
  });

}).call(this);
