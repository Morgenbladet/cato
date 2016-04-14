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
  //const HOSTNAME = 'http://localhost:3000';
  const HOSTNAME = 'https://cato.herokuapp.com';

  var root_div;
  var spinner;

  var init = function() {
    root_div = $("#cato_root");
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
        } else {
          root_div.append("<p><em>Ingen nominasjoner funnet.</em></p>");
        }
      })
      .fail(function() {
        root_div.append("<p>Kunne ikke laste nominasjonene…</p>");
      })
      .always(function() {
        hide_spinner();
      });
  }

  var featured_nominations = function() {
    clear();
    root_div.append("<h2>Ti tilfeldig valgte:</h2>");
    var button = $("<button>Hent ti nye!</button>");
    button.click(featured_nominations);
    root_div.append(button);
    list_nominations('/nominations/random.json');
  }

  var institution_nominations = function(institution) {
    clear();
    root_div.append("<h2>" + institution.name + "</h2>");
    list_nominations('/nominations.json?institution=' + institution.id);
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
    fb.append('<a href="https://www.facebook.com/share.php?u=https://morgenbladet.no/fantastiskeformidlere#institution=' + data.institution_id + '" onclick="return mb15_fb_click(this)" target="_blank" title="Del på facebook" class="icon"></a>');
    ul.append(fb);
    ul.append(tw);
    var string = encodeURIComponent("Nominert til fantastiske formidlere: " + data.name);
    var url = encodeURIComponent("https://morgenbladet.no/fantastiskeformidlere#institution=" + data.institution_id);
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

  var institution_show = function(id) {
    clear_and_spinner();
    var back_link = $("<a href='#institutions'>« Andre institusjoner</a>");
    back_link.click(institutions_index);
    root_div.append(back_link);

    $.get(HOSTNAME + '/institutions/' + id + ".json")
      .done(function(data) {
        root_div.prepend($("<h2>" + data.name + "</h2>"));
      });

    $.get(HOSTNAME + '/nominations.json?institution=' + id)
      .done(function(data) {
        if(data.length == 0) {
          root_div.append($("<p>Ingen har nominert noen herfra ennå. Nominér din favoritt!</p>"));
        } else {
          var ul = $("<ul class='nomination_list'></ul>");
          $.each(data, function(index, element) {
            ul.append(nomination_li(element));
          });
          root_div.append(ul);
        }
      })
      .fail(function() {
        root_div.append($("<p>En feil oppstod under henting av nominasjoner.</p>"));
      })
      .always(function() {
        hide_spinner();
        var form = submission_form(id);
        root_div.append("<h2>Nominér din favoritt</h2>");
        root_div.append(submission_form(id));
        window.location.hash = "institution=" + id;
        $.scrollTo(root_div, -50);
      });

  }

  var input_div = function(field, description, type) {
    if (type == 'undefined')
      type = 'text';
    var div = $("<div class='input_field'></div>");
    var fld_name = "nomination["+field +"]";
    div.append($("<label for='" + fld_name + "'>" + description + "</label><br/>"));
    div.append($("<input name='" + fld_name + "' type='" + type + "'/>"));
    return(div);
  };

  var submission_form = function(institution_id) {
    var form = $("<form id='submission'></form>");
    form.append("<p>Studenter, tidligere studenter, kolleger, tilfeldige publikummere – alle kan nominere. På nettsiden kan du også lese andres nominasjoner, stemme frem kandidater og dele nominasjonene videre.</p><p>Nominasjonene og stemmene danner grunnlaget for juryens videre utvelgelse, og begrunnelsen er derfor viktig. Prøv å gi en presis beskrivelse av undervisningen på maksimalt 2000 tegn. Frist for å nominere er 15. april. Juryens liste med ti navn presenteres i august.</p>");
    form.append($("<input name='nomination[institution_id]' type='hidden' value='" + institution_id + "'/>"));
    form.append(input_div("name", "Navn på den nominerte:"));
    form.append(input_div("nominator", "Ditt navn:"));
    form.append(input_div("nominator_email", "Din e-post:", 'email'));
    var ta = $("<div class='input_field'></div>");
    ta.append($("<label for='nomination[reason]'>Begrunnelse:</label><br/>"));
    ta.append($("<textarea name='nomination[reason]' cols='30' rows='10'></textarea>"));
    form.append(ta);
    form.append($("<button type='submit'>Send nominasjon!</button>"));

    form.submit(function(e) {
      $.post(HOSTNAME + '/nominations.json', $("#submission").serialize())
        .done(function(data) {
          alert('Din nominasjon er mottatt. Den blir behandlet manuelt før den vises på denne siden.');
          institutions_index();
        })
        .fail(function(data) {
          alert('Noe gikk galt med denne nominasjonen. Forsøk gjerne igjen.\n\n' + data.responseText);
        });
      e.preventDefault();
    });

    return(form);
  };


  init();

});
