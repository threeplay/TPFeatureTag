//
//  Created by Eliran Ben-Ezra on 10/28/18.
//

import Foundation

public class FeatureTag: CustomStringConvertible, Equatable, Hashable {
  public static func == (lhs: FeatureTag, rhs: FeatureTag) -> Bool {
    return lhs.name == rhs.name && lhs.nameSpace == rhs.nameSpace && lhs.key == rhs.key
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(nameSpace)
  }

  internal let defaultEnabled: Bool
  internal var resolver: FeatureTagResolver?
  public internal(set) var nameSpace: String = ""
  public internal(set) var name: String = "(unnamed feature)"
  public let key: String?

  internal init(key: String?, enabled: Bool) {
    self.defaultEnabled = enabled
    self.key = key
  }

  public var isOn: Bool {
    return resolver?.resolve(self).isOn ?? defaultEnabled
  }

  public var source: String {
    return resolver?.resolve(self).source ?? FeatureTags.Manager.defaultSource
  }

  public var description: String {
    return "\(nameSpace)::\(name)(\(isOn), default: \(defaultEnabled))"
  }
}
