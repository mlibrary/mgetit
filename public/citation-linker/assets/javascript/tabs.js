var tab_config = [
  {
    tab: 'tab1',
    content: 'article_form'
  },
  {
    tab: 'tab2',
    content: 'book_form'
  }
]

var handle_tabs = function(tab_data) {
  var tab_clicked = function(tab) {
    hide_all_content()

    document.getElementById(tab.content).classList.remove('hidden')
  }

  var hide_all_content = function() {
    _.each(tab_data, function(tab) {
      document.getElementById(tab.content).classList.add('hidden')
    })
  }

  // Iterate over each tab and setup event handler on tab click
  _.each(tab_data, function(tab) {
    var element = document.getElementById(tab.tab)
    element.addEventListener('click', function() { tab_clicked(tab) })
  })
}

handle_tabs(tab_config)
