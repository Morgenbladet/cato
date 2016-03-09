jQuery(function($) {
  const HOSTNAME = 'http://localhost:3000';

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

    $.get(HOSTNAME + "/institutions.json")
      .done(function(data) {
        $.each(data, function(index, element) {
          root_div.append(institution_box(element));
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


  var institution_show = function(id) {
    clear_and_spinner();

    $.get(HOSTNAME + '/nominations.json?institution=' + id)
      .done(function(data) {
      
      })
      .fail(function() {

      })
      .always(function() {
        hide_spinner();
      });
  }

  institutions_index();
});
