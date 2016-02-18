
App.ConfigurationsIndexRoute = Ember.Route.extend

    model: () ->
        @store.find 'configuration'


App.ConfigurationsCreateRoute = Ember.Route.extend
    model: ->
        configuration = @store.createRecord('configuration', { })
        configuration.get('sliders').pushObject(@store.createRecord('slider', slider)) for slider in [
            { size: 512, unit: 'b'  }
            { size: 4,   unit: 'kb' }
            { size: 8,   unit: 'kb' }
            { size: 32,  unit: 'kb' }
            { size: 64,  unit: 'kb' }
            { size: 128, unit: 'kb' }
            { size: 512, unit: 'kb' }
            { size: 1,   unit: 'mb' }
        ]
        configuration

    actions:
        goToIndex: (scope, cb) ->
            @transitionTo('configurations.index').then( () ->
                cb.call(scope) if typeof cb is 'function'
            )


App.ConfigurationsEditRoute = App.ConfigurationsCreateRoute.extend
    model: (params) ->
        @store.find('configuration', params.id)