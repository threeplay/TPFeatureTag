import XCTest
import Nimble
@testable import TPFeatureTag

class FeatureTagTestOverridesTests: XCTestCase {

  class TestFeatures {
    let feature1 = makeFeature()
    let feature2 = makeFeature(enabled: true)
  }

  var manager: FeatureTags.Manager!
  let features = TestFeatures()

  override func setUp() {
    super.setUp()
    manager = FeatureTags.Manager()
    manager.register(features)
  }

  func test_that_features_can_be_overridden_for_test() {
    FeatureTags.testOverride(.enable(features.feature1)) {
      expect(self.features.feature1.isOn).to(beTrue())
      expect(self.features.feature2.isOn).to(beTrue())
    }
    FeatureTags.testOverride(.disable(features.feature2)) {
      expect(self.features.feature1.isOn).to(beFalse())
      expect(self.features.feature2.isOn).to(beFalse())
    }
    FeatureTags.testOverride(.enable(features.feature1), .disable(features.feature2)) {
      expect(self.features.feature1.isOn).to(beTrue())
      expect(self.features.feature2.isOn).to(beFalse())
    }
    FeatureTags.testOverride {
      expect(self.features.feature1.isOn).to(beFalse())
      expect(self.features.feature2.isOn).to(beTrue())
    }
  }
}
