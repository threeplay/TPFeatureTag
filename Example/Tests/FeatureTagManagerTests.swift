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

  let testFeatures = TestFeatures()
  let otherTestFeatures = OtherTestFeatures()
  var manager: FeatureTagManager!

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
}
