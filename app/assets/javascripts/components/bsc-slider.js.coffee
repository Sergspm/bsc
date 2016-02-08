



App.BscSliderComponent = Ember.Component.extend
    model: null

    units: {
        'b': 'Bytes'
        'kb': 'KB'
        'mb': 'MB'
        'gb': 'GB'
    }

    focused: false
    available: 0
    maximum: 100

    slideGerm: null

    didInsertElement: () ->
        @set('slideGerm', @$().find('.slide-germ'))
        @get('slideGerm').slider({
            reversed: true
            min: 0
            max: @get('maximum')
            step: 1
            value: parseInt @get('model.value')
            orientation: 'vertical'
            tooltip: 'hide'
        }).slider('setAvailable', @get('available'))

    updateValue: () ->
        @setValue(@get('model.value')) if @get('focused')
        @sendAction('onValueChange', @)

    setValue: (value) ->
        value = parseInt(value)
        value = 0 unless isFinite(value)
        @set('model.value', value)
        @get('slideGerm').slider('setValue', value)

    getValue: () ->
        @get('model.value')

    changeAvailable: ( () ->
        @get('slideGerm')?.slider('setAvailable', @get('available'))
    ).observes('available')

    changeValue: ( () ->
        @updateValue()
    ).observes('model.value')

    changeMaximum: ( () ->
        @get('slideGerm').slider('setAttribute', 'max', @get('maximum'))
    ).observes('maximum')

    actions:
        onRemove: () ->
            @get('model').deleteRecord()
            @sendAction('onRemove', @)

        focusOut: () ->
            @set('focused', false)

        focusIn: () ->
            @set('focused', true)