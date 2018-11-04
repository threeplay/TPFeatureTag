//
//  Resolvers.swift
//  TPFeatureTag
//
//  Created by Eliran Ben-Ezra on 10/30/18.
//

import Foundation

extension FeatureTags {
  enum Resolvers {
  }
}

extension FeatureTags.Resolvers {
  class Local: FeatureTagGetter, FeatureTagSetter {
    let namespace: String
    private let userDefaults: UserDefaults

    init(namespace: String = "featuretag") {
      self.namespace = namespace
      self.userDefaults = UserDefaults.standard
    }

    func isOn(feature: FeatureTag) -> Bool? {
      return userDefaults.object(forKey: feature.localKey(prefix: namespace)) as? Bool
    }

    func set(feature: FeatureTag, isOn: Bool) {
      userDefaults.set(isOn, forKey: feature.localKey(prefix: namespace))
    }

    func clear(feature: FeatureTag) {
      userDefaults.removeObject(forKey: feature.localKey(prefix: namespace))
    }
  }
}

private extension FeatureTag {
  func localKey(prefix: String) -> String {
    return "\(prefix)_\(key ?? "\(namespace)_\(name)")"
  }
}
