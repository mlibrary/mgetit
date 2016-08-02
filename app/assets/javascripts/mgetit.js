(function() {

  document.addEventListener("DOMContentLoaded", function(event) {

    /*
      Show More Sources/Links/Results
    */
    // Hide all but the first link on page load and then
    // show the rest of the links when "show more" is clicked.

    var show_more_sources = document.getElementById('show-more-sources');
    var digital_sources = document.getElementById('fulltext-sources').children;

    for (var i = 0; i < digital_sources.length; i++) {
      if (i > 0) {
        addClass(digital_sources[i], 'hide')
      }
    }

    removeClass(show_more_sources, 'hide')

    show_more_sources.addEventListener('click', function(event) {
      event.preventDefault();

      addClass(show_more_sources, 'hide')

      for (var i = 0; i < digital_sources.length; i++) {
        removeClass(digital_sources[i], 'hide')
      }
    })
  })


  /*
    Permalink Clipboard Setup
  */
  new Clipboard('#permalink')


  /*
    Helper Functions
  */
  function addClass(el, className) {
    if (el.classList)
      el.classList.add(className)
    else if (!hasClass(el, className)) el.className += " " + className
  }

  function removeClass(el, className) {
    if (el.classList)
      el.classList.remove(className)
    else if (hasClass(el, className)) {
      var reg = new RegExp('(\\s|^)' + className + '(\\s|$)')
      el.className=el.className.replace(reg, ' ')
    }
  }

})();
