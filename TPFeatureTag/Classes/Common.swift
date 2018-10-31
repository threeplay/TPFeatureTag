//
//  Created by Eliran Ben-Ezra on 10/28/18.
//

import Foundation

public func makeFeature(key: String? = nil, enabled: Bool = false) -> FeatureTag {
  return FeatureTag(key: key, enabled: enabled)
}

public protocol FeatureTagGetter {
  func isOn(feature: FeatureTag) -> Bool?
}

public protocol FeatureTagSetter {
  func set(feature: FeatureTag, isOn: Bool)
  func clear(feature: FeatureTag)
}

public protocol FeatureTagResolver {
  func resolve(_ feature: FeatureTag) -> (source: String, isOn: Bool)
}
