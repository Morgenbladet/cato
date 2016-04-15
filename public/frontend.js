jQuery.scrollTo = function (target, offset, speed, container) {
  if (isNaN(target)) {
    if (!(target instanceof jQuery))
      target = jQuery(target);

    target = parseInt(target.offset().top);
  }

  container = container || "html, body";
  if (!(container instanceof jQuery))
    container = jQuery(container);

  speed = speed || 500
  offset = offset || 0;

  container.animate({
    scrollTop: target + offset
  }, speed);
};

var has_voted_for = function(id) {
  return (parseInt(id) in Cookies.getJSON('cato_voted'));
}

var set_voted_for = function(id) {
  var votes = Cookies.getJSON('cato_voted');
  votes[parseInt(id)] = true;
  Cookies.set('cato_voted', votes);
}

jQuery(function($) {
  var HOSTNAME;
  var root_div;
  var spinner;

  var init = function() {
    root_div = $("#cato_root");
    HOSTNAME = root_div.data('host') || 'https://cato.herokuapp.com';
    filter_div = $("<div class='filter'/>");
    filter_div.append("Velg et lærested:<br/>");
    filter_div.append(filter_select());
    filter_div.append("<br/><br/>Søk på navn:<br/>");
    filter_div.append(filter_text());
    root_div.before(filter_div);

    var vote_cookie = Cookies.getJSON('cato_voted');
    if (typeof vote_cookie == 'undefined') {
      Cookies.set('cato_voted', {})
    }

    spinner = $("<p><img src='//cato.herokuapp.com/img/ripple.svg' id='spinner' style:'display:none'/></p>");
    root_div.before(spinner);

    if (/institution=\d+/.test(window.location.hash)) {
      institution_show(window.location.hash.match(/institution=(\d+)$/)[1]);
    } else if(/nomination=\d+/.test(window.location.hash)) {
      nomination_show(window.location.hash.match(/nomination=(\d+)$/)[1] );
    } else {
      featured_nominations();
    }
  }

  var filter_select = function() {
    var select = $("<select id='institutions'>");
    select.append($('<option selected>–– Alle læresteder</option>'));

    select.change(function() {
      inst = $("#institutions option:selected").data();
      if (typeof inst.id == 'undefined') {
        featured_nominations();
      } else {
        institution_nominations(inst);
      }
    });

    $.get(HOSTNAME + "/institutions.json")
      .done(function(data) {
        $.each(data, function(index, element) {
          select.append($('<option/>', {
            value: element.id,
            text:  element.name + " (" + element.nominations_count + ")",
            data:  element
          }));
        });
      })
      .fail(function() {
        select.replaceWith($("<p>Kunne ikke laste institusjonene...</p>")); 
      });

    return(select);
  }

  var filter_text = function() {
    var field = $("<input/>", {
      id: 'cato_search',
      type: 'text',
      placeholder: 'Navn'
    });

    var button = $('<button/>', {
      class: 'searchbutton',
      text: 'Søk'
    });

    button.click(function() {
      var txt = $("#cato_search").val();
      if (txt == '') {
        featured_nominations();
      } else {
        search(txt);
      }
    });

    var fs = $("<span>");
    fs.append(field);
    fs.append(button);

    return(fs);
  };


  var clear_and_spinner = function() {
    clear();
    spin();
  }

  var clear = function() { root_div.html(''); }

  var spin = function() { spinner.show(); }

  var hide_spinner = function() {
    spinner.hide();
  }


  var list_nominations = function (uri) {
    spin();
    var ul = $("<ul/>");

    $.get(HOSTNAME + uri)
      .done(function(data) {
        if (data.length) {
          $.each(data, function(index, element) {
            var li = nomination_li(element);
            ul.append(li);
            li.hide();
            li.delay(index*200).fadeIn(500);
          });
          root_div.append(ul);
        } else if (typeof data.name !== 'undefined') {
          root_div.append(nomination_li(data));
        } else {
          root_div.append("<p><em>Ingen nominasjoner funnet.</em></p>");
        }
        root_div.append(random_button('Hent ti tilfeldige'));
      })
      .fail(function() {
        root_div.append("<p>Kunne ikke laste nominasjonene…</p>");
      })
      .always(function() {
        hide_spinner();
      });
  }

  var random_button = function(txt) {
    var button = $("<button>" + txt + "</button>");
    button.click(featured_nominations);
    return(button);
  }

  var featured_nominations = function() {
    clear();
    root_div.append("<h2>Ti tilfeldig valgte:</h2>");
    root_div.append(random_button('Hent ti nye'));
    list_nominations('/nominations/random.json');
  }

  var institution_nominations = function(institution) {
    clear();
    root_div.append("<h2>" + institution.name + "</h2>");
    list_nominations('/nominations.json?institution=' + institution.id);
  }

  var institution_show = function(id) {
    clear();
    spin();
    $.get(HOSTNAME + '/institutions/' + id + '.json')
      .done(function(data) {
        institution_nominations(data);
      })
      .fail(function() {
        root_div.append("Fant ikke lærestedet...");
      })
      .always(function() {
        hide_spinner();
      });
  }

  var nomination_show = function(id) {
    list_nominations('/nominations/' + id + '.json');
  }

  var search = function(txt) {
    clear();
    txt = encodeURIComponent(txt);
    root_div.append("<h2>Søk: " + txt + "</h2>");
    list_nominations('/nominations.json?search=' + txt);
  }

  var notify_error = function(error) {
    root_div.html("En feil oppstod: " + error);
  };

  var social_icons = function(data) {
    var div = $("<div class='social-icons'></div>");
    var ul = $("<ul>");
    var fb = $("<li class='fb'></li>");
    var tw = $("<li class='tw'></li>");
    fb.append('<a href="https://www.facebook.com/share.php?u=https://morgenbladet.no/fantastiskeformidlere#nomination=' + data.id + '" onclick="return mb15_fb_click(this)" target="_blank" title="Del på facebook" class="icon"></a>');
    ul.append(fb);
    ul.append(tw);
    var string = encodeURIComponent("Nominert til fantastiske formidlere: " + data.name);
    var url = encodeURIComponent("https://morgenbladet.no/fantastiskeformidlere#nomination=" + data.id);
    tw.append('<a href="https://twitter.com/intent/tweet?text=' + string + '&amp;url=' + url + '&amp;via=Morgenbladet" onclick="return mb15_tw_click(this)" target="_blank" title="Del på Twitter" class="icon"></a>');
    div.append(ul);
    return(div);
  };


  var vote_button = function(id) {
    button = $("<button class='votebutton'>✔ Støtt denne nominasjonen!</button>");

    if (has_voted_for(id)) {
      button.prop('disabled', true);
      button.text('✔ Du har støttet denne!');
    }

    button.click(function(e) {
      $.post(HOSTNAME + '/nominations/' + id + '/vote.json')
        .done(function(data) {
          $(e.currentTarget).prop('disabled', true);
          $(e.currentTarget).text('✔ Du har støttet denne!');
          set_voted_for(id);
          alert("Din stemme er mottatt!");
        })
        .fail(function(data) {
          alert("En feil oppstod: " + data.responseText);
        });
    });

    return(button);
  }

  var nomination_li = function(data) {
    var li = $("<li class='nomination'></li>");
    li.append(social_icons(data));
    li.append("<h3>" + data.name + "</h3>");
    li.append("<small>" + data.institution.name + "</small>");
    $.each(data.reasons, function(index, element) {
      var div = $("<div class='reason'>");
      div.append("<blockquote>" + element.reason_html + "</blockquote>");
      div.append("<p class='nominator'>– " + element.nominator + "</p>");
      li.append(div);
    });
    li.append(vote_button(data.id));
    return(li);
  };


  init();

});
