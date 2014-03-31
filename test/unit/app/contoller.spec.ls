describe "controllers", ->

  beforeEach(module "App")

  describe "About" (,) ->
    it "About" inject ($controller, $rootScope) ->
      $scope = $rootScope.$new!
      $controller "About" {$scope}
      expect $rootScope.activeTab .to.equal 'about'

