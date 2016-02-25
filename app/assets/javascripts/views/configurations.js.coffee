
Ember.LinkView.reopen
    attributeBindings: [ 'data-toggle' ]


Ember.Select.reopen
    attributeBindings: [ 'data-toggle' ]


App.ConfigurationsView = Ember.View.extend
    classNames: [ 'container' ]


App.ConfigurationsCreateView = Ember.View.extend
    classNames: [ 'bsc-modal' ]

App.ConfigurationsEditView = Ember.View.extend
    classNames: [ 'bsc-modal' ]