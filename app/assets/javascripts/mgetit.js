(function() {

  var dismiss = function() {
    var dismiss_elements = document.getElementsByClassName('dismiss');

    var dismissElement = function() {
      addClass(document.getElementById(this.getAttribute('data-dismiss')), 'hide')
    }

    for (var i = 0; i < dismiss_elements.length; i++) {
      var element = dismiss_elements[i];
      element.addEventListener('click', dismissElement);
    }
  }

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

  document.addEventListener("DOMContentLoaded", function(event) {
    dismiss()
  })

})();
