//
//  Created by Eliran Ben-Ezra on 10/28/18.
//

import XCTest
import Nimble
@testable import TPFeatureTag

class FeatureTagManagerTests: XCTestCase {

  class TestFeatures {
    let f1 = makeFeature()
    let f2 = makeFeature(key: "123")
    let f3 = makeFeature(enabled: true)
    let ignoreBool = true
    let ignoreString = "123"
    let ignoreInt = 123
  }

  class OtherTestFeatures {
    let f1 = makeFeature()
  }

  class Getter: FeatureTagGetter {
    var value = [FeatureTag: Bool]()

    func isOn(feature: FeatureTag) -> Bool? {
      return value[feature]
    }
  }

  class MockResolver: Getter, FeatureTagSetter {
    enum Action: Equatable {
      case set(FeatureTag, state: Bool)
      case clear(FeatureTag)
    }

    var actions = [Action]()

    func set(feature: FeatureTag, isOn: Bool) {
      value[feature] = isOn
      actions.append(.set(feature, state: isOn))
    }

    func clear(feature: FeatureTag) {
      value.removeValue(forKey: feature)
      actions.append(.clear(feature))
    }
  }

  let testFeatures = TestFeatures()
  let otherTestFeatures = OtherTestFeatures()
  var mockGetter = Getter()
  var mockResolver = MockResolver()

  var manager: FeatureTags.Manager!

  override func setUp() {
    super.setUp()
    manager = FeatureTags.Manager()
  }

  func test_that_feature_returns_default_if_it_was_never_registered() {
    expect(makeFeature().isOn).to(beFalse())
    expect(makeFeature(enabled: true).isOn).to(beTrue())
  }

  func test_that_feature_returns_default_source_if_it_was_never_registered() {
    expect(makeFeature().source).to(equal(FeatureTags.Manager.defaultSource))
  }

  func test_that_instance_always_returns_the_same_instance() {
    expect(FeatureTags.Manager.instance) === FeatureTags.Manager.instance
  }

  func test_that_non_feature_tag_instance_vars_are_ignored() {
    manager.register(testFeatures)
    expect(self.manager.allFeatures.map { $0.name }).toNot(contain(["ignoreBool", "ignoreString", "ignoreInt"]))
  }

  func test_that_registered_features_have_the_correct_name_space() {
    let expectedNameSpace = "TestFeatures"
    manager.register(testFeatures)
    manager.register(otherTestFeatures)
    expect(self.testFeatures.f1.namespace).to(equal(expectedNameSpace))
    expect(self.testFeatures.f2.namespace).to(equal(expectedNameSpace))
    expect(self.testFeatures.f3.namespace).to(equal(expectedNameSpace))
    expect(self.otherTestFeatures.f1.namespace).to(equal("OtherTestFeatures"))
  }

  func test_that_registered_features_have_the_correct_name() {
    manager.register(testFeatures)
    expect(self.testFeatures.f1.name).to(equal("f1"))
    expect(self.testFeatures.f2.name).to(equal("f2"))
    expect(self.testFeatures.f3.name).to(equal("f3"))
  }

  func test_that_it_can_register_features() {
    manager.register(testFeatures)
    let ourFeatures = manager.allFeatures.filter { $0.namespace == "TestFeatures" }
    expect(ourFeatures).to(contain([testFeatures.f1, testFeatures.f2, testFeatures.f3]))
  }

  func test_that_resolvers_can_be_installed() {
    manager.install(name: "local", priority: 1, resolver: mockGetter)
    manager.register(testFeatures)
    mockGetter.value[testFeatures.f1] = true
    expect(self.testFeatures.f1.isOn).to(beTrue())
    mockGetter.value = [:]
    expect(self.testFeatures.f1.isOn).to(beFalse())
  }

  func test_that_features_return_the_default_value() {
    manager.register(testFeatures)
    expect(self.testFeatures.f1.isOn).to(beFalse())
    expect(self.testFeatures.f3.isOn).to(beTrue())
  }

  func test_that_features_return_the_values_source() {
    manager.install(name: "local", priority: 1, resolver: mockGetter)
    manager.register(testFeatures)
    expect(self.testFeatures.f1.source).to(equal("default"))
    mockGetter.value[testFeatures.f1] = true
    expect(self.testFeatures.f1.source).to(equal("local"))
  }

  func test_that_feature_tags_can_move_to_a_new_manager() {
    manager.register(testFeatures)
    manager.install(name: "local", priority: 1, resolver: mockGetter)
    mockGetter.value[testFeatures.f1] = true
    let otherManager = FeatureTags.Manager()
    otherManager.register(testFeatures)
    expect(self.testFeatures.f1.isOn).to(beFalse())
  }

  func test_that_feature_tags_can_be_registered_multiple_times_to_the_same_manager() {
    manager.register(testFeatures)
    manager.register(testFeatures)
    expect(self.manager.allFeatures.count).to(equal(3))
  }

  func test_that_resolvers_are_evaluated_in_decending_priority_order() {
    let priority1 = Getter()
    let priority2 = Getter()
    let priority3 = Getter()
    manager.install(name: "p1", priority: 1, resolver: priority1)
    manager.install(name: "p3", priority: 3, resolver: priority3)
    manager.install(name: "p2", priority: 2, resolver: priority2)

    priority1.value[testFeatures.f1] = true
    expect(self.manager.resolve(self.testFeatures.f1).source).to(equal("p1"))
    priority2.value[testFeatures.f1] = false
    priority3.value[testFeatures.f1] = false
    expect(self.manager.resolve(self.testFeatures.f1).source).to(equal("p3"))
    priority3.value = [:]
    expect(self.manager.resolve(self.testFeatures.f1).source).to(equal("p2"))
  }

  func test_that_individual_resolvers_can_be_requested_to_override_a_feature_value() {
    let resolver = MockResolver()
    manager.install(name: "mock", priority: 1, resolver: resolver)
    manager.set(testFeatures.f1, to: true, in: "mock")
    expect(resolver.actions).to(contain([MockResolver.Action.set(testFeatures.f1, state: true)]))
    manager.set(testFeatures.f2, to: true, in: "other")
    expect(resolver.actions).toNot(contain([MockResolver.Action.set(testFeatures.f2, state: true)]))
  }

  func test_that_individual_resolvers_can_be_request_to_reset_a_feature_value() {
    let resolver = MockResolver()
    manager.install(name: "mock", priority: 1, resolver: resolver)
    manager.clear(testFeatures.f1, in: "mock")
    expect(resolver.actions).to(contain([MockResolver.Action.clear(testFeatures.f1)]))
    manager.clear(testFeatures.f2, in: "other")
    expect(resolver.actions).toNot(contain([MockResolver.Action.clear(testFeatures.f2)]))
  }

  func test_that_all_resolvers_can_be_requested_to_override_a_feature_value() {
    let resolver1 = MockResolver()
    let resolver2 = MockResolver()
    manager.install(name: "mock", priority: 1, resolver: resolver1)
    manager.install(name: "other", priority: 2, resolver: resolver2)
    manager.set(testFeatures.f1, to: true)
    expect(resolver1.actions).to(contain([MockResolver.Action.set(testFeatures.f1, state: true)]))
    expect(resolver1.actions).to(contain([MockResolver.Action.set(testFeatures.f1, state: true)]))
  }

  func test_that_all_resolvers_can_be_requested_to_reset_a_feature_value() {
    let resolver1 = MockResolver()
    let resolver2 = MockResolver()
    manager.install(name: "mock", priority: 1, resolver: resolver1)
    manager.install(name: "other", priority: 2, resolver: resolver2)
    manager.clear(testFeatures.f1)
    expect(resolver1.actions).to(contain([MockResolver.Action.clear(testFeatures.f1)]))
    expect(resolver2.actions).to(contain([MockResolver.Action.clear(testFeatures.f1)]))
  }

}
