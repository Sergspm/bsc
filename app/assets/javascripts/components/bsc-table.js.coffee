
App.BscTableComponent = Ember.Component.extend
    classNames: [ 'slider-item' ]

    model: null

    confirmedToRemove: null

    isRemovedProcess: false

    notifyType: ''
    notifyMessage: ''
    notifyExtra: []

    didInsertElement: () ->
        @$().find('[data-toggle="tooltip"]').tooltip()

    hasError: Ember.computed.bool('errorMessage')

    hasSuccess: Ember.computed.bool('successMessage')

    actions:
        confirmRemoveConfiguration: (configuration) ->
            @set('confirmedToRemove', configuration)

        stopRemove: () ->
            @set('confirmedToRemove', null)

        removeConfiguration: () ->
            unless @get('isRemovedProcess')
                self = @
                done = (type, message) ->
                    self.set('notifyType', type)
                    self.set('notifyMessage', message)
                    self.set('confirmedToRemove', null)
                    self.set('isRemovedProcess', false)
                    self.rerender()
                @set('isRemovedProcess', true)
                configuration = @get('confirmedToRemove')
                configuration.deleteRecord()
                configuration.save().then( (() ->
                    done('success', 'Configuration successfully deleted')
                ), ( () ->
                    done('error', 'The configuration was deleted earlier')
                ))