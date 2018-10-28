open class FeatureTagsHolder {
  public init() {
    FeatureTagManager.instance.register(self)
  }
}

public func makeFeature(key: String? = nil, enabled: Bool = false) -> FeatureTagManager.Feature {
  return FeatureTagManager.Feature(key: key, enabled: enabled)
}

public class FeatureTagManager {
  public static let instance = FeatureTagManager()

  private var registeredFeatures = [String: Feature]()

  private init() {
  }

  public class Feature: CustomStringConvertible, Equatable {
    public static func == (lhs: FeatureTagManager.Feature, rhs: FeatureTagManager.Feature) -> Bool {
      return lhs.name == rhs.name && lhs.nameSpace == rhs.nameSpace && lhs.key == rhs.key
    }

    internal let defaultEnabled: Bool
    public internal(set) var nameSpace: String = ""
    public internal(set) var name: String = "(unnamed feature)"
    internal let key: String?

    internal init(key: String?, enabled: Bool) {
      self.defaultEnabled = enabled
      self.key = key
    }

    public var isOn: Bool {
      return FeatureTagManager.instance.resolve(self).isOn
    }

    public var description: String {
      return "\(nameSpace)::\(name)(\(isOn), default: \(defaultEnabled))"
    }
  }

  public var allFeatures: [Feature] {
    return registeredFeatures.values.map { $0 }
  }

  public func resolve(_ feature: Feature) -> (source: String, isOn: Bool) {
    return (source: "default", isOn: feature.defaultEnabled)
  }

  public func register(_ holder: Any) {
    let mirror = Mirror(reflecting: holder)
    let featureNameSpace = String(describing: mirror.subjectType)
    mirror.children.forEach { child in
      guard let featureName = child.label, let feature = child.value as? Feature else { return }
      let nameSpacedFeatureName = "\(featureNameSpace).\(featureName)"
      feature.nameSpace = featureNameSpace
      feature.name = featureName
      guard registeredFeatures[nameSpacedFeatureName] == nil else { return }
      registeredFeatures[nameSpacedFeatureName] = feature
    }
  }
}
