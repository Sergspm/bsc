#= require jquery
#= require jquery_ujs
#= require handlebars
#= require ember
#= require ember-data
#= require active-model-adapter
#= require bootstrap/build/js/bootstrap.js
#= require bootstrap-select/dist/js/bootstrap-select.js
#= require seiyria-bootstrap-slider/dist/bootstrap-slider.js
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./templates
#= require_tree ./routes
#= require_tree ./adapters
#= require_tree ./mixins
#= require_tree ./helpers
#= require_tree ./components
#= require ./router


# for more details see: http://emberjs.com/guides/application/

Ember.LOG_VERSION = false

window.App = Ember.Application.create
    LOG_TRANSITIONS: false
    LOG_TRANSITIONS_INTERNAL: false
    LOG_VIEW_LOOKUPS: false
    LOG_ACTIVE_GENERATION: false

    viewRegistry:
        modal: null
        base: null




