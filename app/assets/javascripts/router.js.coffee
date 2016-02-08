
App.Router = Ember.Router.extend
    location: 'none'


App.Router.map () ->
    @resource 'configurations', path: '/', () ->
        @route 'create', path: '/create'
        @route 'edit', path: '/edit/:id'
