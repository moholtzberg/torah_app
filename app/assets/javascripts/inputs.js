function createSubjectPicker(selector) {
  var config = {
    shouldSort: false,
    searchFloor: 2,
    searchChoices: false,
    duplicateItems: false,
    noResultsText: 'No results found',
    noChoicesText: 'Type subject name you want to learn'
  };

  const elem = $(selector)[0];

  // Construct the Choices object.
  var choices = new Choices(elem, config);

  // Some config and bookkeeping for API calls.
  var apiUrl = '/lessons/subjects';
  var lookupDelay = 100;
  var lookupTimeout = null;
  var lookupCache = {};

  // Function to perform the API lookup.
  function serverLookup() {
    const query = choices.input.value;
    if (query in lookupCache) {
      populateOptions(lookupCache[query]);
    } else {
      $.get(apiUrl, { search: query })
        .then((subjects) =>  {
          console.log("test")
          lookupCache[query] = subjects;
          populateOptions(subjects);
        })
      };

      function populateOptions(options) {
        choices.setChoices(options, 'value', 'label', true);
      };
    }

    elem.addEventListener('search', function(event) {
      clearTimeout(lookupTimeout);
      lookupTimeout = setTimeout(serverLookup, lookupDelay);
    });

    elem.addEventListener('choice', function(event) {
      choices.setChoices([], 'value', 'label', true);
    });

    return choices;
}

function createLanguagePicker(selector) {
  var config = {
    removeItemButton: true,
    maxItemCount: 5
  };

  console.log(config)

  const elem = $(selector)[0];

  const choices = new Choices(elem, config);

  return choices;
}
