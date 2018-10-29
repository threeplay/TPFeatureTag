open class FeatureTagsHolder {
  public init() {
    FeatureTagManager.instance.register(self)
  }
}

public func makeFeature(key: String? = nil, enabled: Bool = false) -> FeatureTagManager.Feature {
  return FeatureTagManager.Feature(key: key, enabled: enabled)
}

public protocol FeatureTagResolver {
  func isOn(feature: FeatureTagManager.Feature) -> Bool?
}

public protocol FeatureTagOverride {
  func set(feature: FeatureTagManager.Feature, isOn: Bool)
  func clear(feature: FeatureTagManager.Feature)
}

public class FeatureTagManager {
  private var registeredFeatures = [String: Feature]()
  private var installedResolvers = [Resolver]()

  public class Feature: CustomStringConvertible, Equatable, Hashable {
    public static func == (lhs: FeatureTagManager.Feature, rhs: FeatureTagManager.Feature) -> Bool {
      return lhs.name == rhs.name && lhs.nameSpace == rhs.nameSpace && lhs.key == rhs.key
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
      hasher.combine(nameSpace)
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

  public static let instance = FeatureTagManager()

  public var allFeatures: [Feature] {
    return registeredFeatures.values.map { $0 }
  }

  public func resolve(_ feature: Feature) -> (source: String, isOn: Bool) {
    for resolver in installedResolvers {
      if let isOn = resolver.instance.isOn(feature: feature) {
        return (source: resolver.name, isOn: isOn)
      }
    }
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

  public func install(name: String, priority: UInt, resolver: FeatureTagResolver) {
    let r = Resolver(name: name, priority: priority, instance: resolver)
    guard !installedResolvers.contains(r) else {
      fatalError("A resolver with same priority already exists (installing: \(r) existing: \(String(describing: installedResolvers.first { r == $0 }))))")
    }
    installedResolvers = (installedResolvers + [r]).sorted()
  }

  private struct Resolver: Comparable {
    static func == (lhs: FeatureTagManager.Resolver, rhs: FeatureTagManager.Resolver) -> Bool {
      return lhs.priority == rhs.priority
    }

    static func < (lhs: FeatureTagManager.Resolver, rhs: FeatureTagManager.Resolver) -> Bool {
      return lhs.priority < rhs.priority
    }

    let name: String
    let priority: UInt
    let instance: FeatureTagResolver
  }

  private init() {
  }


}
