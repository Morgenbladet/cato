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

jQuery(function($) {
  var root_div = $("#cato_root");
  const HOSTNAME = root_div.data('host') || 'https://cato.herokuapp.com';

  var spinner = $("<img src='//cato.herokuapp.com/img/ripple.svg' id='spinner' style:'display:none'/>");
  root_div.prepend(spinner);

  var clear_and_spinner = function() {
    root_div.html('');
    spinner.show();
  }

  var hide_spinner = function() {
    spinner.hide();
  }

  var institutions_index = function () {
    clear_and_spinner();
    window.location.hash = "institutions";
    $.get(HOSTNAME + "/institutions.json")
      .done(function(data) {
        root_div.append("<p>Klikk på ditt universitet/høyskole for å lese nominasjoner eller bidra med din egen.</p>");
        $.each(data, function(index, element) {
          var box = institution_box(element);
          root_div.append(box);
          box.hide();
          box.delay(index * 100).fadeIn(200);
        });
      })
      .fail(function() {
        notify_error("Kunne ikke laste studiestedene. Prøv på nytt senere.");
      })
      .always(function() {
        hide_spinner();
        $.scrollTo(root_div, -50);
      });
  }

  var notify_error = function(error) {
    root_div.html("En feil oppstod: " + error);
  };

  var institution_box = function(institution) {
    var anchor = $("<a href='#'></a>");
    anchor.data({ action: 'show-institution', id: institution.id });
    var element = $("<div class='institution'></div>");
    element.append("<h3>" + institution.name + "</h3>");
    anchor.append(element);
    anchor.click(function() {
      institution_show($(this).data('id'));
    });
    return(anchor);
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
    button.click(function(e) {
      $.post(HOSTNAME + '/nominations/' + id + '/vote.json')
        .done(function(data) {
          $(e.currentTarget).prop('disabled', true);
          alert("Din stemme er mottatt!");
        })
        .fail(function(data) {
          alert("En feil oppstod: " + data.responseText);
        });
    });

    return(button);
  }

  var nomination_li = function(data) {
    var element = $("<li class='nomination'></li>");
    element.append("<h3>" + data.name + "</h3>");
    element.append("<div class='reason'><b>Begrunnelse:</b> " + data.reasons_merged + "</div>");
    element.append("<p><i>Nominert av " + data.nominator + "</i></p>");
    element.append(vote_button(data.id));
    element.append(social_icons(data));
    return(element);
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
    var fld_name = field;
    div.append($("<label for='" + fld_name + "'>" + description + "</label><br/>"));
    div.append($("<input name='" + fld_name + "' type='" + type + "'/>"));
    return(div);
  };

  var submission_form = function(institution_id) {
    var form = $("<form id='submission'></form>");
    form.append("<p>Studenter, tidligere studenter, kolleger, tilfeldige publikummere – alle kan nominere. På nettsiden kan du også lese andres nominasjoner, stemme frem kandidater og dele nominasjonene videre.</p><p>Nominasjonene og stemmene danner grunnlaget for juryens videre utvelgelse, og begrunnelsen er derfor viktig. Prøv å gi en presis beskrivelse av undervisningen på maksimalt 2000 tegn. Frist for å nominere er 15. april. Juryens liste med ti navn presenteres i august.</p>");
    form.append($("<input name='nomination[institution_id]' type='hidden' value='" + institution_id + "'/>"));
    form.append(input_div("nomination[name]", "Navn på den nominerte:"));
    form.append(input_div("nomination[reasons_attributes][0][nominator]", "Ditt navn:"));
    form.append(input_div("nomination[reasons_attributes][0][nominator_email]", "Din e-post:", 'email'));
    var ta = $("<div class='input_field'></div>");
    ta.append($("<label for='reason'>Begrunnelse:</label><br/>"));
    ta.append($("<textarea name='nomination[reasons_attributes][0][reason]' cols='30' rows='10' id='reason'></textarea>"));
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

  if (/institution=\d+/.test(window.location.hash)) {
    institution_show(window.location.hash.match(/institution=(\d+)$/)[1]);
  } else {
    institutions_index();
  }
});
