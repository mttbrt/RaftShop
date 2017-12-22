// CLIENT

function getItemsListAsClient(request) {
  $.ajax({
    url: '/ClientRequest',
    contentType: "application/json",
    data: JSON.stringify(request),
    type: 'POST',
    success: function(response) {
      if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
        redirectToLeader(response);
      else
        fillTable(response);
    }
  })
}

function getItemsListByCart(request) {
  $.ajax({
    url: '/ClientRequest',
    contentType: "application/json",
    data: JSON.stringify(request),
    type: 'POST',
    success: function(response) {
      if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
        redirectToLeader(response);
      else
        fillTable(response);
    }
  })
}

function createNewCart(request) {
  $.ajax({
      url: '/ClientRequest',
      contentType: "application/json",
      data: JSON.stringify(request),
      type: 'POST',
      success: function(response) {
        if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
          redirectToLeader(response);
        else {
          var result = response.result;
          if(result)
            displaySuccess(response.msg);
          else
            displayError(response.msg);
        }
      }
  })
}

function buyCart(request) {
  $.ajax({
      url: '/ClientRequest',
      contentType: "application/json",
      data: JSON.stringify(request),
      type: 'POST',
      success: function(response) {
        if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
          redirectToLeader(response);
        else {
          var result = response.result;
          if(result)
            displaySuccess(response.msg);
          else
            displayError(response.msg);
        }
      }
  })
}

function deleteCart(request) {
  $.ajax({
      url: '/ClientRequest',
      contentType: "application/json",
      data: JSON.stringify(request),
      type: 'POST',
      success: function(response) {
        if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
          redirectToLeader(response);
        else {
          var result = response.result;
          if(result)
            displaySuccess(response.msg);
          else
            displayError(response.msg);
        }
      }
  })
}

function addItemToCart(request) {
  $.ajax({
      url: '/ClientRequest',
      contentType: "application/json",
      data: JSON.stringify(request),
      type: 'POST',
      success: function(response) {
        if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
          redirectToLeader(response);
        else {
          var result = response.result;
          if(result)
            displaySuccess(response.msg);
          else
            displayError(response.msg);
        }
      }
  })
}

function removeItemFromCart(request) {
  $.ajax({
      url: '/ClientRequest',
      contentType: "application/json",
      data: JSON.stringify(request),
      type: 'POST',
      success: function(response) {
        if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
          redirectToLeader(response);
        else {
          var result = response.result;
          if(result)
            displaySuccess(response.msg);
          else
            displayError(response.msg);
        }
      }
  })
}

// ADMIN

function getItemsListAsAdmin(request) {
  $.ajax({
    url: '/AdminRequest',
    contentType: "application/json",
    data: JSON.stringify(request),
    type: 'POST',
    success: function(response) {
      if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
        redirectToLeader(response);
      else
        fillTable(response);
    }
  })
}

function addItemToList(request) {
  $.ajax({
    url: '/AdminRequest',
    contentType: "application/json",
    data: JSON.stringify(request),
    type: 'POST',
    success: function(response) {
      if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
        redirectToLeader(response);
      else {
        var result = response.result;
        if(result)
          displaySuccess(response.msg);
        else
          displayError(response.msg);
      }
    }
  })
}

function removeItemFromList(request) {
  $.ajax({
    url: '/AdminRequest',
    contentType: "application/json",
    data: JSON.stringify(request),
    type: 'POST',
    success: function(response) {
      if(response.address) // Se ho contattato un server diverso dal leader reindirizzo
        redirectToLeader(response);
      else {
        var result = response.result;
        if(result)
          displaySuccess(response.msg);
        else
          displayError(response.msg);
      }
    }
  })
}

// REDIRECT
var leaderLink = window.location.href;

function redirectToLeader(request) {
  $('#leaderRedirectionModal').modal();

  var address = request.address.replace(/(^:)|(:$)/g, '').split(":");
  leaderLink = 'http://localhost:' + address[2] + window.location.pathname;

  countdownAndRedirect(6);
}

function countdownAndRedirect(seconds, link) {
    seconds = seconds - 1;
    if (seconds < 0)
        window.location = leaderLink;
    else {
        $('#time').text(seconds);
        window.setTimeout("countdownAndRedirect(" + seconds + ")", 1000);
    }
}

// TITLE ANIMATION

var count = 0;

function TxtRotate(el, toRotate, period) {
  this.toRotate = toRotate;
  this.el = el;
  this.loopNum = 0;
  this.period = parseInt(period, 10) || 2000;
  this.txt = '';
  this.tick();
  this.isDeleting = false;
}

TxtRotate.prototype.tick = function() {
  var i = this.loopNum % this.toRotate.length;
  var fullTxt = this.toRotate[i];

  if (this.isDeleting) {
    this.txt = fullTxt.substring(0, this.txt.length - 1);
  } else {
    this.txt = fullTxt.substring(0, this.txt.length + 1);
  }

  this.el.innerHTML = '<span class="wrap">'+this.txt+'</span>';

  var that = this;
  var delta = 300 - Math.random() * 100;

  if (this.isDeleting) { delta /= 2; }

  if (!this.isDeleting && this.txt === fullTxt) {
    delta = this.period;
    this.isDeleting = true;
  } else if (this.isDeleting && this.txt === '') {
    this.isDeleting = false;
    this.loopNum++;
    delta = 500;
  }

  count++;

  if(count<25) {
    setTimeout(function() {
      that.tick();
    }, delta);
  } else {
    $("style").remove();
  }
};

// GRAPHICS

$(document).ready(function() {

  // Title Animation
  $('.txt-rotate').each(function() {
    var toRotate = $(this).attr('data-rotate');
    var period = $(this).attr('data-period');
    if (toRotate) {
      new TxtRotate(this, JSON.parse(toRotate), period);
    }
  });

  $(document.body).append('<style>.txt-rotate > .wrap { border-right: 0.08em solid #666 }</style>'); // Inject css

  // Client
  $("#redirect").click(function() {
    window.location.replace("/client.html");
  });

  $("#getItemsListAsClient").click(function(){
    getItemsListAsClient(
      {
        code: 1,
        data:""
      }
    );
  });

  $("#createNewCart").click(function(){
    var noSpaces = $('#c_name').val().replace(/ /g, '');
    if(noSpaces.length > 0) {
      createNewCart(
        {
          code: 2,
          data:
            {
              name:noSpaces
            }
        }
      );
    } else {
      displayError("Cart name cannot be empty.");
    };
  });

  $("#buyCart").click(function(){
    var noSpaces = $('#c_name').val().replace(/ /g, '');
    if(noSpaces.length > 0) {
      buyCart(
        {
          code: 3,
          data:
            {
              name:noSpaces
            }
        }
      );
    } else {
      displayError("Cart name cannot be empty.");
    };
  });

  $("#deleteCart").click(function(){
    var noSpaces = $('#c_name').val().replace(/ /g, '');
    if(noSpaces.length > 0) {
      deleteCart(
        {
          code: 4,
          data:
            {
              name:noSpaces
            }
        }
      );
    } else {
      displayError("Cart name cannot be empty.");
    };
  });

  $("#getItemsListByCart").click(function(){
    var noSpaces = $('#c_name').val().replace(/ /g, '');
    if(noSpaces.length > 0) {
      getItemsListByCart(
        {
          code: 5,
          data: {
            name:noSpaces
          }
        }
      );
    } else {
      displayError("Cart name cannot be empty.");
    };
  });

  $("#addItemToCart").click(function(){
    var noSpaces1 = $('#i_cart').val().replace(/ /g, '');
    var noSpaces2 = $('#i_name').val().replace(/ /g, '');
    if(noSpaces1.length > 0 && noSpaces2.length > 0) {
      if($.isNumeric($('#i_qnt').val())) {
        addItemToCart(
          {
            code: 6,
            data:
              {
                cartName:noSpaces1,
                itemName:noSpaces2,
                itemQnt:$('#i_qnt').val()
              }
          }
        );
      } else {
        displayError("Quantity field must be a number.");
      }
    } else {
      displayError("No field can be empty.");
    };
  });

  $("#removeItemFromCart").click(function(){
    var noSpaces1 = $('#i_cart').val().replace(/ /g, '');
    var noSpaces2 = $('#i_name').val().replace(/ /g, '');
    if(noSpaces1.length > 0 && noSpaces2.length > 0) {
      if($.isNumeric($('#i_qnt').val())) {
        removeItemFromCart(
          {
            code: 7,
            data:
              {
                cartName:noSpaces1,
                itemName:noSpaces2,
                itemQnt:$('#i_qnt').val()
              }
          }
        );
      } else {
        displayError("Quantity field must be a number.");
      }
    } else {
      displayError("No field can be empty.");
    };
  });

  // Admin
  $("#getItemsListAsAdmin").click(function(){
    getItemsListAsAdmin(
      {
        code: 1,
        data:""
      }
    );
  });

  $("#addItemToList").click(function() {
    var noSpaces = $('#a_i_name').val().replace(/ /g, '');
    if(noSpaces.length > 0) {
      if($.isNumeric($('#a_i_qnt').val())) {
        addItemToList(
          {
            code: 2,
            data:
              {
                itemName:noSpaces,
                itemQnt:$('#a_i_qnt').val()
              }
          }
        );
      } else {
        displayError("Quantity field must be a number.");
      }
    } else {
      displayError("Item name cannot be empty.");
    };
  });

  $("#removeItemFromList").click(function(){
    var noSpaces = $('#a_i_name').val().replace(/ /g, '');
    if(noSpaces.length > 0) {
      if($.isNumeric($('#a_i_qnt').val())) {
        removeItemFromList(
          {
            code: 3,
            data:
              {
                itemName:noSpaces,
                itemQnt:$('#a_i_qnt').val()
              }
          }
        );
      } else {
        displayError("Quantity field must be a number.");
      }
    } else {
      displayError("Item name cannot be empty.");
    };
  });

  // Chiusura popups
  $(".close").click(function(){
    var id = "#" + $(this).closest('div').attr('id');
    $(id).stop(true, true).fadeOut();
    $(id).hide();
  });

  // Redirect link
  $('#redirectBtn').click(function(){
     window.location.href = leaderLink;
  });

});

// POP-UPS

function displaySuccess(msg) {
  hideActivePops();

  $("#success-alert p").html(msg);

  $("#success-alert").show();
  setTimeout(function() {
      $("#success-alert").fadeOut(1500);
  }, 2000);
}

function displayError(msg) {
  hideActivePops();

  $("#danger-alert p").html(msg);

  $("#danger-alert").show();
  setTimeout(function() {
      $("#danger-alert").fadeOut(1500);
  }, 2000);
}

function hideActivePops() {
  $("#success-alert").stop(true, true).fadeOut();
  $("#success-alert").hide();
  $("#danger-alert").stop(true, true).fadeOut();
  $("#danger-alert").hide();
}

// ITEMS TABLE

function fillTable(response) {
  $("#items-table tbody tr").remove();

  $.each(response, function(i, item) {
      var $row = $('<tr>').append(
          $('<td>').text(item.name),
          $('<td>').text(item.quantity)
      ).appendTo('#items-table');
      $row.html();
  });
}
