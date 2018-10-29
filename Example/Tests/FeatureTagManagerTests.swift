import XCTest
import Nimble
@testable import TPFeatureTag

class FeatureTagManagerTests: XCTestCase {

  class TestFeatures {
    let f1 = makeFeature()
    let f2 = makeFeature(key: "123")
    let f3 = makeFeature(enabled: true)
  }

  class OtherTestFeatures {
    let f1 = makeFeature()
  }

  class Resolver: FeatureTagResolver {
    var value = [FeatureTagManager.Feature: Bool]()

    func isOn(feature: FeatureTagManager.Feature) -> Bool? {
      return value[feature]
    }
  }

  let testFeatures = TestFeatures()
  let otherTestFeatures = OtherTestFeatures()
  var manager: FeatureTagManager!
  var mockResolver = Resolver()

  override func setUp() {
    super.setUp()
    manager = FeatureTagManager.instance
  }

  func test_that_instance_always_returns_the_same_instance() {
    expect(self.manager) === FeatureTagManager.instance
  }

  func test_that_registered_features_have_the_correct_name_space() {
    let expectedNameSpace = "TestFeatures"
    manager.register(testFeatures)
    manager.register(otherTestFeatures)
    expect(self.testFeatures.f1.nameSpace).to(equal(expectedNameSpace))
    expect(self.testFeatures.f2.nameSpace).to(equal(expectedNameSpace))
    expect(self.testFeatures.f3.nameSpace).to(equal(expectedNameSpace))
    expect(self.otherTestFeatures.f1.nameSpace).to(equal("OtherTestFeatures"))
  }

  func test_that_registered_features_have_the_correct_name() {
    manager.register(testFeatures)
    expect(self.testFeatures.f1.name).to(equal("f1"))
    expect(self.testFeatures.f2.name).to(equal("f2"))
    expect(self.testFeatures.f3.name).to(equal("f3"))
  }

  func test_that_it_can_register_features() {
    manager.register(testFeatures)
    let ourFeatures = manager.allFeatures.filter { $0.nameSpace == "TestFeatures" }
    expect(ourFeatures).to(contain([testFeatures.f1, testFeatures.f2, testFeatures.f3]))
  }

  func test_that_resolvers_can_be_installed() {
    manager.install(name: "local", priority: 1, resolver: mockResolver)
    manager.register(testFeatures)
    mockResolver.value[testFeatures.f1] = true
    expect(self.testFeatures.f1.isOn).to(beTrue())
    mockResolver.value = [:]
    expect(self.testFeatures.f1.isOn).to(beFalse())
  }

  func test_that_resolvers_are_evaluated_in_asending_priority_order() {
    let priority1 = Resolver()
    let priority2 = Resolver()
    let priority3 = Resolver()
    manager.install(name: "p1", priority: 1, resolver: priority1)
    manager.install(name: "p3", priority: 3, resolver: priority3)
    manager.install(name: "p2", priority: 2, resolver: priority2)

    priority3.value[testFeatures.f1] = true
    expect(self.manager.resolve(self.testFeatures.f1).source).to(equal("p3"))
    priority2.value[testFeatures.f1] = false
    priority1.value[testFeatures.f1] = false
    expect(self.manager.resolve(self.testFeatures.f1).source).to(equal("p1"))
    priority1.value = [:]
    expect(self.manager.resolve(self.testFeatures.f1).source).to(equal("p2"))
  }
}
