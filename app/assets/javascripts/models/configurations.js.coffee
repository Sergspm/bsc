


App.Configuration = DS.Model.extend
    primaryKey: '_id'

    sliders: DS.hasMany('slider', { inverse: 'configuration' })

    _id:             DS.attr('string', { defaultValue: ''      })
    confType:        DS.attr('string', { defaultValue: 'bins'  })
    constantSize:    DS.attr('string', { defaultValue: '512 b' })
    randomFromUnit:  DS.attr('string', { defaultValue: 'kb'    })
    randomToUnit:    DS.attr('string', { defaultValue: 'kb'    })
    randomFromValue: DS.attr('number', { defaultValue: 16      })
    randomToValue:   DS.attr('number', { defaultValue: 16      })

    addSlider: (conf) ->
        @get('sliders').pushObject(@store.createRecord('slider', conf))

    getCanonicalSlidersSizes: () ->
        factor = { b: 1, kb: 1024, mb: 1024 * 1024, gb: 1024 * 1024 * 1024 }
        @get('sliders').map((slider) ->
            slider.get('size') * factor[slider.get('unit')]
        )

    readableName: ( () ->
        name = ''
        units = { 'b': 'Bytes', 'kb': 'KB', 'mb': 'MB', 'gb': 'GB' }
        switch @get('confType')
            when 'constant'
                name = 'Constant: ' + @get('constantSize').toUpperCase()
            when 'random'
                name = "Random: from #{@get('randomFromValue')} #{units[@get('randomFromUnit')]} to #{@get('randomToValue')} #{units[@get('randomToUnit')]}"
            when 'bins'
                name = @get('sliders').map((slide) -> "#{slide.get('size')} #{units[slide.get('unit')]} - #{slide.get('value')}%").join(', ')
        name
    ).property('confType', 'sliders.@each.{size,unit,value}')

    avg: ( -> # сумма(размер * процент) / сумма(процент)
        sizes = { b: 1, kb: 1024, mb: 1024 * 1024, gb: 1024 * 1024 * 1024 }
        units = { 'b': 'Bytes', 'kb': 'KB', 'mb': 'MB', 'gb': 'GB' }
        toReadableAvg = (avg_val) ->
            cValue = null
            cUnit = null
            for unit, value of sizes
                if cValue == null
                    cValue = value
                    cUnit = unit
                if avg_val <= value then break
                cValue = value
                cUnit = unit
            Math.round(avg_val / cValue) + ' ' + units[cUnit]

        switch @get('confType')
            when 'constant'
                return @get('constantSize').toUpperCase()
            when 'random'
                return toReadableAvg((@get('randomFromValue') * sizes[@get('randomFromUnit')] + @get('randomToValue') * sizes[@get('randomToUnit')]) / 2)
            when 'bins'
                sum = 0
                sumVal = 0
                @get('sliders').forEach (slide) ->
                    sum += slide.get('size') * sizes[slide.get('unit')] * slide.get('value')
                    sumVal += slide.get('value')
                return toReadableAvg(sum / sumVal || 0)
    ).property('confType', 'sliders.@each.{size,unit,value}', 'randomFromValue', 'randomFromUnit', 'randomToValue', 'randomToUnit')

    isConstantType: Ember.computed.equal('confType', 'constant')

    isRandomType: Ember.computed.equal('confType', 'random')

    isBinType: Ember.computed.equal('confType', 'bins')


App.Slider = DS.Model.extend
    primaryKey: '_id'

    size: DS.attr('number', { defaultValue: 1 })
    unit: DS.attr('string', { defaultValue: 'kb' })
    value: DS.attr('number', { defaultValue: 0 })

    configuration: DS.belongsTo('configuration')

    toDelete: DS.attr('boolean', { defaultValue: false })

    sizeLabel: ( () ->
        units = { 'b': 'Bytes', 'kb': 'KB', 'mb': 'MB', 'gb': 'GB' }
        @get('size') + ' ' + units[@get('unit')]
    ).property('size', 'unit')


App.ApplicationSerializer = DS.RESTSerializer.extend
    primaryKey: "_id"

    serializeId: (id) ->
        id.toString()

    keyForAttribute: (attr, method) ->
        Ember.String.underscore(attr)

    serialize: (record, options) ->
        json =  this._super(record, options)
        if record.typeKey is 'slider'
            delete json.configuration
            delete json.to_delete
            record.record.set('toDelete', true) if record.record.get('id') is null
        json


App.ConfigurationSerializer = App.ApplicationSerializer.extend(DS.EmbeddedRecordsMixin, {
    attrs: {
        sliders: {
            embedded: 'always'
        }
    }
})