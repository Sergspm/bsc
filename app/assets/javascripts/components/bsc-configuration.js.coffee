
# Duplicate issue: https://github.com/emberjs/data/issues/1829
# 12345678901234 KB


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

    notifyType: ''
    notifyMessage: ''
    notifyExtra: []

    isSavingProcess: false

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

    maxSlidersValue: 0

    deletedSliders: []

    onInit: ( () ->
        @storeRandValues()
    ).on 'init'

    didInsertElement: () ->
        @set('maxSlidersValue', @get('model').maxSlidersValue())
        @initSelectPicker()
        @recheckAvailable()

    initSelectPicker: (reload) ->
        select = @$().find('[data-toggle="select"]')
        select.selectpicker
            size: 20
            showIcon: true
            width: 'fit'
        if reload
            Ember.run.scheduleOnce('afterRender', @, () ->
                select.selectpicker('refresh')
            )

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

    setSliderMaximumOptions: ( () ->
        Ember.run.scheduleOnce('afterRender', @, () ->
            @initSelectPicker(true)
        )
        max = @get('maxSlidersValue')
        [
            { label: '100%', value: 100 }
            { label: '80%',  value: 80  }
            { label: '60%',  value: 60  }
            { label: '40%',  value: 40  }
            { label: '20%',  value: 20  }
        ].map( (item) ->
            Ember.Object.create({ label: item.label,  value: item.value, disabled: item.value < max })
        )
    ).property('maxSlidersValue')

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

    changeRndVal: ( (view, propertyName) ->
        value = @get(propertyName)
        parsed = parseInt(value) || 0
        @set(propertyName, parsed) unless value + '' is parsed + ''
    ).observes('model.randomFromValue', 'model.randomToValue')

    watchInSliders: (() ->
        @get('model.sliders').forEach((slide) ->
            slide.deleteRecord() if slide?.get('toDelete')
        )
    ).observes('model.sliders.@each')

    applymaxSlidersValue: ( () ->
        @recheckAvailable()
    ).observes('setSliderMaximum')

    isAddBinButtonDisabled: (() ->
        @addNewBinErrorCode() != ''
    ).property('addBinValue', 'addBinUnit', 'model.sliders.[]')

    addNewBinErrorCode: () ->
        size = @get('addBinValue')
        unit = @get('addBinUnit')
        factor = { b: 1, kb: 1024, mb: 1024 * 1024, gb: 1024 * 1024 * 1024 }
        return 'empty' if size is ''
        return 'too-long' if size.length > 14
        return 'invalid' unless isFinite(parseInt(size))
        return 'max-sliders' if @get('model.sliders').length >= @get('maxSliders')
        return 'exists' if @get('model').getCanonicalSlidersSizes().indexOf(size * factor[unit]) >= 0
        ''

    actions:
        goBack: () ->
            if @get('isEdit')
                @sendAction('onGoBack')
                Ember.run.once(@, () ->
                    @get('model').rollback()
                    @get('deletedSliders').forEach( (slider) ->
                        slider.rollback()
                    )
                    @set('deletedSliders', [])
                )
            else
                @get('model').deleteRecord()
                @sendAction('onGoBack', @)

        onSlideRemove: (slider) ->
            if @get('model.sliders').length > 1
                @get('deletedSliders').pushObject(slider.get('model'))
                slider.deleteSlider()
                @recheckAvailable()
            else
                @set('notifyType', 'error')
                @set('notifyMessage', 'You\'re can\'t remove all sliders. Add at least one new slider to remove first.')

        onSliderValueChange: (currentSlider) ->
            @set('maxSlidersValue', @get('model').maxSlidersValue())
            @recheckAvailable(currentSlider)

        saveConfiguration: () ->
            unless @get('isSavingProcess')
                errorMessage = null
                if @get('model.isBinType')
                    errorMessage = 'Total percentage must be a 100' unless @get('model').isBinValid()
                if @get('model.isRandomType')
                    errorMessage = 'Random must have a non zero values and "from" must be greater than "to"' unless @get('model').isRandomValid()
                unless errorMessage
                    self = @
                    @set('isSavingProcess', true)
                    @get('model').save().then(( (configuration) ->
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
                        self.set('isSavingProcess', true)
                    ))
                else
                    @set('notifyType', 'error')
                    @set('notifyMessage', errorMessage)

        addBin: () ->
            err = @addNewBinErrorCode()
            if err == ''
                @get('model').addSlider({
                    size: @get('addBinValue')
                    unit: @get('addBinUnit')
                    value: 0
                })
                @set('addBinValue', '')
            else
                switch err
                    when 'max-sliders' then err = 'The limit of sliders has been reached'
                    when 'exists' then err = 'You can not set already existed size'
                    else err = ''
                if err != ''
                    @set('notifyType', 'error')
                    @set('notifyMessage', err)