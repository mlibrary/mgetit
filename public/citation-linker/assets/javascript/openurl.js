var openurl = function() {
  var settings = {
    base_url: 'https://mgetit.lib.umich.edu/resolve',
    sid: 'info:sid:lib.umich.edu'
  }

  var create = function(type, query_string_hash) {
    if (query_string_hash == undefined) {
      throw "openurl create missing query string hash"
    }

    return settings.base_url
                + '?'
                + get_format_query(type)
                + '&sid=' + encodeURIComponent(settings.sid)
                + create_query_strings().generate(query_string_hash)
  }

  var get_format_query = function(type) {
    switch (type) {
      case 'journal':
        return encodeURIComponent('rft_val_fmt') + '=' + encodeURIComponent('info:ofi/fmt:kev:mtx:journal') + '&rft.genre=Article'
      case 'book':
        return encodeURIComponent('rft_val_fmt') + '=' + encodeURIComponent('info:ofi/fmt:kev:mtx:book') + '&rft.genre=Book'
    }
  }

  return {
    create: create
  }
}

var create_query_strings = function() {
  var create_query_string = function(value) {
    if (value.key == undefined) {
      throw "query string missing key"
    }

    if (value.value == undefined) {
      throw "query string missing value"
    }

    // DOIs and PMIDs are special snowflakes
    if (value.key == 'doi') {
      // Example: &rft_id=info:doi=10.1111/1468-232X.00264
      return '&' + encodeURIComponent('rft_id') + '=' + encodeURIComponent('info:doi=' + value.value)
    }

    if (value.key == 'pmid') {
      // Example: &rft_id=info:pmid=27405801
      return '&' + encodeURIComponent('rft_id') + '=' + encodeURIComponent('info:pmid/' + value.value)
    }

    return '&' + encodeURIComponent(value.key) + '=' + encodeURIComponent(value.value)
  }

  var generate = function(query_string_hash) {

    return _.reduce(query_string_hash, function(base, value) {
      return base = base + create_query_string(value)
    }, '')
  }

  return {
    generate: generate
  }
}
