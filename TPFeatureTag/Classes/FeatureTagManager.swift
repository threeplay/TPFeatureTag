//
//  Created by Eliran Ben-Ezra on 10/29/18.
//

open class FeatureTags {
  public init(manager: FeatureTags.Manager = FeatureTags.Manager.instance) {
    manager.register(self)
  }
}

public extension FeatureTags {
  public class Manager: FeatureTagResolver {
    public static let instance = Manager()

    static let defaultSource = "default"
    static let testOverrideSource = "testOverride"

    private var registeredFeatures = [String: FeatureTag]()
    private var installedResolvers = [Resolver]()
    private var testOverrideGetter: FeatureTagGetter?

    internal func installTestOverride(getter: FeatureTagGetter) {
      testOverrideGetter = getter
    }

    internal func removeTestOverride() {
      testOverrideGetter = nil
    }

    public var allFeatures: [FeatureTag] {
      return registeredFeatures.values.map { $0 }
    }

    public func register(_ holder: Any) {
      let mirror = Mirror(reflecting: holder)
      let featureNamespace = String(describing: mirror.subjectType)
      mirror.children.forEach { child in
        guard let featureName = child.label, let feature = child.value as? FeatureTag else { return }
        let namespacedFeatureName = "\(featureNamespace).\(featureName)"
        feature.namespace = featureNamespace
        feature.name = featureName
        feature.resolver = self
        guard registeredFeatures[namespacedFeatureName] == nil else { return }
        registeredFeatures[namespacedFeatureName] = feature
      }
    }

    public func install(name: String, priority: UInt, getter: FeatureTagGetter) {
      let resolver = Resolver(name: name, priority: priority, getter: getter)
      installedResolvers = (installedResolvers + [resolver]).sorted()
    }

    public func resolve(_ feature: FeatureTag) -> (source: String, isOn: Bool) {
      if let getter = testOverrideGetter, let isOn = getter.isOn(feature: feature) {
        return (source: Manager.testOverrideSource, isOn: isOn)
      }
      for resolver in installedResolvers {
        if let isOn = resolver.isOn(feature: feature) {
          return (source: resolver.name, isOn: isOn)
        }
      }
      return (source: Manager.defaultSource, isOn: feature.defaultEnabled)
    }
  }

  private struct Resolver: Comparable {
    static func == (lhs: Resolver, rhs: Resolver) -> Bool {
      return lhs.priority == rhs.priority
    }

    static func < (lhs: Resolver, rhs: Resolver) -> Bool {
      return lhs.priority < rhs.priority
    }

    let name: String
    let priority: UInt
    let getter: FeatureTagGetter

    func isOn(feature: FeatureTag) -> Bool? {
      return getter.isOn(feature: feature)
    }
  }
}
