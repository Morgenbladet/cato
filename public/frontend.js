jQuery(function($) {
  //const HOSTNAME = 'http://localhost:3000';
  const HOSTNAME = 'https://cato.herokuapp.com';

  var root_div = $("#cato_root");
  var spinner = $("<img src='img/ripple.svg' id='spinner' style:'display:none'/>");
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

  var nomination_li = function(data) {
    var element = $("<li class='nomination'></li>");
    element.append("<h3>" + data.name + "</h3>");
    element.append("<div class='reason'>«" + data.reason + "»</div>");
    return(element);
  };

  var institution_show = function(id) {
    clear_and_spinner();
    window.location.hash = "institution=" + id;
    var back_link = $("<a href='#institutions'>« Alle institusjoner</a>");
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
        root_div.append(submission_form(id));
      });

  }

  var input_div = function(field, description) {
    var div = $("<div class='input_field'></div>");
    div.append($("<span class='field_text'>" + description + "</span><br/>"));
    div.append($("<input name='nomination[" + field + "]'/>"));
    return(div);
  };

  var submission_form = function(institution_id) {
    var form = $("<form id='submission'></form>");
    form.append($("<input name='nomination[institution_id]' type='hidden' value='" + institution_id + "'/>"));
    form.append(input_div("name", "Navn på den nominerte:"));
    form.append(input_div("nominator", "Ditt navn:"));
    form.append(input_div("nominator_email", "Din e-post:"));
    var ta = $("<div class='input_field'></div>");
    ta.append($("<span class='field_text'>Begrunnelse:</span><br/>"));
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

  if (/institution=\d+/.test(window.location.hash)) {
    institution_show(window.location.hash.match(/institution=(\d+)$/)[1]);
  } else {
    institutions_index();
  }
  institutions_index();
});
