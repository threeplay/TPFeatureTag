import XCTest
import Nimble
@testable import TPFeatureTag


class TestFeatureTag: FeatureTags {
  let feature1 = makeFeature()
  let feature2 = makeFeature()
}

class FeatureTagsHolderTests: XCTestCase {
  private let testFeatureTagManager = FeatureTags.Manager()
  private var tags: TestFeatureTag!

  override func setUp() {
    super.setUp()
    tags = TestFeatureTag(manager: testFeatureTagManager)
  }

  func test_that_feature_tags_can_be_registered_to_specific_manager() {
    expect(self.testFeatureTagManager.allFeatures).to(contain([tags.feature1, tags.feature2]))
  }
}
