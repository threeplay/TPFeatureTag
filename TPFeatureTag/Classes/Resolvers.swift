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
    let nameSpace: String
    private let userDefaults: UserDefaults

    init(nameSpace: String = "featuretag") {
      self.nameSpace = nameSpace
      self.userDefaults = UserDefaults.standard
    }

    func isOn(feature: FeatureTag) -> Bool? {
      return userDefaults.object(forKey: feature.localKey(prefix: nameSpace)) as? Bool
    }

    func set(feature: FeatureTag, isOn: Bool) {
      userDefaults.set(isOn, forKey: feature.localKey(prefix: nameSpace))
    }

    func clear(feature: FeatureTag) {
      userDefaults.removeObject(forKey: feature.localKey(prefix: nameSpace))
    }
  }
}

private extension FeatureTag {
  func localKey(prefix: String) -> String {
    return "\(prefix)_\(key ?? "\(namespace)_\(name)")"
  }
}
