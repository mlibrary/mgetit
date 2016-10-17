var citation_linker = function() {
  var initialize = function(forms) {
    // Setup form submit event handler
    _.each(forms, function(form) {
      var form_element = document.getElementById(form.form_id)

      // Search for form submit element within form
      _.each(form_element.childNodes, function(child_node) {
        if (child_node.type == 'submit') {
          child_node.addEventListener("click", function(event) {
            event.preventDefault()
            form_submit(form)
          })
        }
      })
    })
  }

  var form_submit = function(form) {
    var form_elements = document.getElementById(form.form_id).querySelectorAll('[data-openurlkey]')

    var form_openurl_keys = _.reduce(form_elements, function(memo, node) {
      if (node.value == "") {
        return memo
      } else {
        return memo.concat({
          key: node.dataset.openurlkey,
          value: node.value
        })
      }
    }, [])

    // If part of the form is filled out
    if (form_openurl_keys.length > 0) {
      // Redirect
      window.location = openurl().create(form.type, form_openurl_keys)
    }
  }

  return {
    init: initialize
  }
}

// pass in an array of IDs associated with each form
citation_linker().init([
  {
    form_id: 'article_form',
    type: 'journal'
  }, {
    form_id: 'book_form',
    type: 'book'
  }
])
