



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
        self = @
        @set('slideGerm', @$().find('.slide-germ'))
        @get('slideGerm').slider({
            reversed: true
            min: 0
            max: @get('maximum')
            step: 1
            value: parseInt @get('model.value')
            orientation: 'vertical'
            tooltip: 'hide'
        }).slider('setAvailable', @get('available')).on('slideStart', () ->
            self.set('focused', false)
        )

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
        @set('model.value', @get('maximum')) if @get('focused') && @get('model.value') > @get('maximum')
        @updateValue()
    ).observes('model.value')

    changeMaximum: ( () ->
        max = @get('maximum')
        @get('slideGerm').slider('setAttribute', 'max', max)
        value = @get('model.value')
        value = max if value > max
        @setValue(value)
    ).observes('maximum')

    deleteSlider: () ->
        @get('model').deleteRecord()

    actions:
        onRemove: () ->
            @sendAction('onRemove', @)

        focusOut: () ->
            @set('focused', false)

        focusIn: () ->
            @set('focused', true)