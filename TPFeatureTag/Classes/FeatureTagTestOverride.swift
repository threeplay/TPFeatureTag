//
//  FeatureTagTestOverride.swift
//  TPFeatureTag
//
//  Created by Eliran Ben-Ezra on 10/29/18.
//

import Foundation

public extension FeatureTags {
  enum OverrideRule {
    case enable(FeatureTag)
    case disable(FeatureTag)

    var featureTag: FeatureTag {
      switch self {
      case .enable(let featureTag), .disable(let featureTag):
        return featureTag
      }
    }

    var isOn: Bool {
      switch self {
      case .enable:
        return true
      case .disable:
        return false
      }
    }
  }

  private class OverrideGetter: FeatureTagGetter {
    private var overrides = [FeatureTag: Bool]()
    init(rules: [OverrideRule]) {
      rules.forEach { overrides[$0.featureTag] = $0.isOn }
    }

    func isOn(feature: FeatureTag) -> Bool? {
      return overrides[feature]
    }
  }

  static func testOverride(_ rules: FeatureTags.OverrideRule..., testBlock: () -> Void) {
    let overrides = OverrideGetter(rules: rules)
    rules.forEach { ($0.featureTag.resolver as? FeatureTags.Manager)?.installTestOverride(getter: overrides) }
    defer {
      rules.forEach { ($0.featureTag.resolver as? FeatureTags.Manager)?.removeTestOverride() }
    }
    testBlock()
  }
}
