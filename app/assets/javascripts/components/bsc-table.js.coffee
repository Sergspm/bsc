
App.BscTableComponent = Ember.Component.extend
    classNames: [ 'slider-item' ]

    model: null

    confirmedToRemove: null

    notifyType: ''
    notifyMessage: ''
    notifyExtra: []

    didInsertElement: () ->
        @$().find('[data-toggle="tooltip"]').tooltip()

    hasConfirmedToRemove: Ember.computed.bool('confirmedToRemove')

    hasError: Ember.computed.bool('errorMessage')

    hasSuccess: Ember.computed.bool('successMessage')

    isChrome: ( () ->
        /Chrome/.test(navigator.userAgent)
    ).property()

    actions:
        confirmRemoveConfiguration: (configuration) ->
            @set('confirmedToRemove', configuration)

        stopRemove: () ->
            #@set('confirmedToRemove', null)

        removeConfiguration: () ->
            self = @
            configuration = @get('confirmedToRemove')
            configuration.deleteRecord()
            configuration.save().then( ->
                self.set('notifyType', 'success')
                self.set('notifyMessage', 'Configuration successfully deleted')
                self.set('confirmedToRemove', null)
            )