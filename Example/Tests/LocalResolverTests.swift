//
//  LocalResolverTests.swift
//  TPFeatureTag_Example
//
//  Created by Eliran Ben-Ezra on 11/1/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
@testable import TPFeatureTag

class LocalResolverTests: XCTestCase {
  var resolver: (FeatureTagGetter & FeatureTagSetter)!
  override func setUp() {
    super.setUp()
    resolver = FeatureTags.Resolvers.Local(namespace: "test")
  }

  func test_that_feature_tag_value_can_be_set() {
    let tag = FeatureTag(key: "1234", enabled: false)
    resolver.clear(feature: tag)
    expect(self.resolver.isOn(feature: tag)).to(beNil())
    resolver.set(feature: tag, isOn: true)
    expect(self.resolver.isOn(feature: tag)).to(beTrue())
    resolver.set(feature: tag, isOn: false)
    expect(self.resolver.isOn(feature: tag)).to(beFalse())
  }

  func test_that_feature_tag_can_be_cleared() {
    let tag = FeatureTag(key: "5431", enabled: false)
    resolver.set(feature: tag, isOn: true)
    expect(self.resolver.isOn(feature: tag)).to(beTrue())
    resolver.clear(feature: tag)
    expect(self.resolver.isOn(feature: tag)).to(beNil())
  }
}
