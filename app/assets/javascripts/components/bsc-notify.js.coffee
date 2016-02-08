

App.BscNotifyComponent = Ember.Component.extend
    classNames: [ 'slider-item' ]

    notifyType: ''
    notifyMessage: ''
    notifyExtra: []

    delay: 3000

    lastRunnedAt: 0

    showNotify: (message, type) ->
        self = @
        types = { error: 'errorMessage', success: 'successMessage' }
        @set(types[type], message)
        Ember.run.later( (() ->
            for key, val of types then self.set(val, null)
        ), 3000);

    hideNotify: (() ->
        self = @
        @set('lastRunnedAt', +new Date)
        Ember.run.later( (() ->
            if !self.isDestroyed && +new Date >= self.get('lastRunnedAt') + self.get('delay')
                self.set('notifyType', '')
                self.set('notifyMessage', '')
                self.set('notifyExtra', [])
        ), @get('delay'))
    ).observes('notifyType', 'notifyMessage', 'notifyExtra.@each')

    isError: Ember.computed.equal('notifyType', 'error')

    isSuccess: Ember.computed.equal('notifyType', 'success')