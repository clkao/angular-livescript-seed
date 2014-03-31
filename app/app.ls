# Declare app level module which depends on filters, and services

angular.module "App" <[app.templates ui.router]>

.config <[$stateProvider $urlRouterProvider $locationProvider]> ++ ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
    .state 'about' do
      url: '/about'
      templateUrl: 'app/partials/about.html'
      controller: "About"
    # Catch all
  $urlRouterProvider
    .otherwise('/about')

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true

.run <[$rootScope $state $stateParams $location $window $anchorScroll]> ++ ($rootScope, $state, $stateParams, $location, $window, $anchorScroll) ->
  $rootScope.$state = $state
  $rootScope.$stateParam = $stateParams
  $rootScope.config_build = require 'config.jsenv' .BUILD
  $rootScope.$on '$stateChangeSuccess' (e, {name}) ->
    window?ga? 'send' 'pageview' page: $location.$$path, title: name

.controller AppCtrl: <[$scope $location $rootScope $sce]> ++ (s, $location, $rootScope, $sce) ->
  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''

.controller About: <[$rootScope $http]> ++ ($rootScope, $http) ->
    $rootScope.activeTab = 'about'
