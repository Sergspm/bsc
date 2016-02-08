
Ember.Handlebars.helper('incr', (value) ->
    if isFinite(parseFloat(value))
        value = parseFloat(value) + 1
     value
)