
# Duplicate issue: https://github.com/emberjs/data/issues/1829

App.BscConfigurationComponent = Ember.Component.extend
    classNames: [ 'bsc-configuration' ]

    model: null
    isEdit: false
    maxSliders: 8
    setSliderMaximum: 100
    availableForUse: 100
    totalAllocated: 0
    addBinValue: ''
    addBinUnit: 'kb'

    randomFromValue: null
    randomToValue: null
    randomFromUnit: null
    randomToUnit: null

    notifyType: ''
    notifyMessage: ''
    notifyExtra: []

    typesLabels: [
        { type: 'constant', label: 'constant block sizes' }
        { type: 'random',   label: 'random block sizes distribution' }
        { type: 'bins',     label: 'bin distribution of block sizes, with custom bins' }
    ]

    constantSizesList: [
        { value: '512 b',  label: '512 Bytes' }
        { value: '1 kb',   label: '1 KB'      }
        { value: '2 kb',   label: '2 KB'      }
        { value: '4 kb',   label: '4 KB'      }
        { value: '8 kb',   label: '8 KB'      }
        { value: '16 kb',  label: '16 KB'     }
        { value: '32 kb',  label: '32 KB'     }
        { value: '64 kb',  label: '64 KB'     }
        { value: '128 kb', label: '128 KB'    }
        { value: '256 kb', label: '256 KB'    }
        { value: '512 kb', label: '512 KB'    }
        { value: '1 mb',   label: '1 MB'      }
    ]

    unitsList: [
        { value: 'b',  label: 'Bytes' }
        { value: 'kb', label: 'KB'    }
        { value: 'mb', label: 'MB'    }
        { value: 'gb', label: 'GB'    }
    ]

    setSliderMaximumOptions: [
        { value: 10,  label: '10%'  }
        { value: 25,  label: '25%'  }
        { value: 50,  label: '50%'  }
        { value: 75,  label: '75%'  }
        { value: 90,  label: '90%'  }
        { value: 100, label: '100%' }
    ]

    onInit: ( () ->
        @storeRandValues()
    ).on 'init'

    didInsertElement: () ->
        @initSelectPicker()
        @recheckAvailable()

    initSelectPicker: () ->
        @$().find('[data-toggle="select"]').selectpicker
            size: 10
            showIcon: true
            width: 'fit'

    storeRandValues: () ->
        model = @get('model')
        @set(name, model.get(name)) for name in [ 'randomFromValue', 'randomToValue', 'randomFromUnit', 'randomToUnit' ]

    recheckAvailable: (currentSlider) ->
        max = 100
        model = @get('model')
        total = 0
        slides = model.get('sliders')
        slides.forEach((slider) -> total += parseInt slider.get('value') )
        delta = total - max
        total = max if total > max
        available = max - total
        @set('totalAllocated', total)
        @set('availableForUse', available)
        currentSlider.setValue(currentSlider.getValue() - delta) if delta > 0 && currentSlider

    isFirefox: ( () ->
        /Firefox/.test(navigator.userAgent) && @get('isEdit')
    ).property()

    availableForUseComputed: (() ->
        available = @get('availableForUse')
        percentage = @get('setSliderMaximum')
        parseInt(available * (100 / percentage))
    ).property('setSliderMaximum', 'availableForUse')

    changeConfigurationType: ( () ->
        Ember.run.scheduleOnce('afterRender', @, () ->
            @initSelectPicker()
        )
    ).observes('model.confType')

    changeRndFromVal: ( (view, propertyName) ->
        model = @get('model')

        factors = { b: 1, kb: 1024, mb: 1024 * 1024, gb: 1024 * 1024 * 1024 }

        propertyName = propertyName.split('.')[1]

        fromValue = parseInt model.get('randomFromValue')
        toValue = parseInt model.get('randomToValue')
        fromUnit = model.get('randomFromUnit')
        toUnit = model.get('randomToUnit')

        fromValue = 0 if !isFinite(fromValue) || fromValue < 0

        model.set('randomFromValue', fromValue)

        fromCanonical = fromValue * factors[fromUnit]

        toValue = Math.ceil(fromCanonical / factors[toUnit]) if !isFinite(toValue) || toValue < 0

        model.set('randomToValue', toValue)

        toCanonical = toValue * factors[toUnit]

        if fromCanonical > toCanonical
            model.set(propertyName, @get(propertyName))
            @set('notifyType', 'error')
            @set('notifyMessage', 'The min value must be less than max value')

        @storeRandValues()
    ).observes('model.randomFromValue', 'model.randomToValue', 'model.randomFromUnit', 'model.randomToUnit')

    ###changeAddBinValue: ( (view, property) ->
        value = parseInt(@get(property))
        value = '' unless isFinite(value)
        @set(property, value)
    ).observes('addBinValue')###

    watchInSliders: (() ->
        @get('model.sliders').forEach((slide) ->
            slide.deleteRecord() if slide?.get('toDelete')
        )
    ).observes('model.sliders.@each')

    applymaxSlidersValue: ( () ->
        @recheckAvailable()
    ).observes('setSliderMaximum')

    isAddBinButtonDisabled: Ember.computed.equal('addBinValue', '')

    actions:
        goBack: () ->
            if @get('isEdit')
                @get('model').rollback()
                @get('model.sliders').forEach((slider) ->
                    slider.rollback()
                )
            @sendAction('onGoBack', @)

        onSlideRemove: (slider) ->
            @recheckAvailable()

        onSliderValueChange: (currentSlider) ->
            @recheckAvailable(currentSlider)

        saveConfiguration: () ->
            self = @
            @get('model.store').findAll('configuration').then( (list) ->
                if list.content.length <= 35
                    self.get('model').save().then(( (configuration) ->
                        self.sendAction('onGoBack', self)
                        self.set('notifyType', 'success')
                        self.set('notifyMessage', 'Configuration successfully saved')
                    ), ( (xhr) ->
                        list = []
                        for field, messages of xhr.responseJSON.errors
                            messages.forEach((message) ->
                                list.push(message)
                            )
                        self.set('notifyType', 'error')
                        self.set('notifyMessage', 'Fail saving configuration:')
                        self.set('notifyExtra', list)
                    ))
                else
                    self.sendAction('onGoBack', self)
                    self.set('notifyType', 'success')
                    self.set('notifyMessage', 'Configuration successfully saved')
            )

        addBin: () ->
            unless (size = @get('addBinValue')) is ''
                unless @get('model.sliders').length >= @get('maxSliders')
                    @get('model').addSlider({
                        size: size
                        unit: @get('addBinUnit')
                        value: 0
                    })
                    @set('addBinValue', '')
                else
                    @set('notifyType', 'error')
                    @set('notifyMessage', 'The limit of sliders has been reached')