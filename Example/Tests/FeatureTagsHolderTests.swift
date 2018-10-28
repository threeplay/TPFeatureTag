import XCTest
import Nimble
@testable import TPFeatureTag

class TestFeatureTag: FeatureTagsHolder {
  let feature1 = makeFeature()
  let feature2 = makeFeature()
}

class FeatureTagsHolderTests: XCTestCase {
  func test_that_subclasses_instance_method_always_return_the_same_instance() {
  }
}
