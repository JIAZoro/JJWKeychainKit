//
//  JJWKeychainKit.swift
//  JJWKeychain
//
//  Created by mrjia on 2019/10/11.
//  Copyright © 2019 norchant. All rights reserved.
//  参考文章： http://www.pianshen.com/article/4425137479/

import Foundation

private let secMatchLimit: String = kSecMatchLimit as String
private let secReturnData: String = kSecReturnData as String
private let secValueData: String = kSecValueData as String
private let secAttrAccessible: String = kSecAttrAccessible as String
private let secClass: String = kSecClass as String
private let secAttrService: String = kSecAttrService as String
private let secAttrGeneric: String = kSecAttrGeneric as String
private let secAttrAccount: String = kSecAttrAccount as String
private let secAttrAccessGroup: String = kSecAttrAccessGroup as String
private let secReturnAttributes: String = kSecReturnAttributes as String

open class JJWKeychainKit {
    /// 单例
    public static let `default` = JJWKeychainKit()

    public private(set) var serviceName: String
    public private(set) var accessGroup: String?
    private static let defaultServiceName: String = {
        Bundle.main.bundleIdentifier ?? "JJWKeychainKit"
    }()

    public init(serviceName: String, accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }

    private convenience init() {
        self.init(serviceName: JJWKeychainKit.defaultServiceName)
    }

    /// 创建字典
    ///
    /// - Parameters:
    ///   - key: key
    ///   - accessibility: 访问方式
    /// - Returns: dic
    private func setupQueryDictionary(forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> [String: Any] {
        var queryDictionary: [String: Any] = [secClass: kSecClassGenericPassword]
        queryDictionary[secAttrService] = serviceName

        if let accessibility = accessibility {
            queryDictionary[secAttrAccessible] = accessibility.keychainAttrValue
        }

        if let accessGroup = accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup
        }

        let encodedKey = key.data(using: .utf8)

        queryDictionary[secAttrGeneric] = encodedKey
        queryDictionary[secAttrAccount] = encodedKey

        return queryDictionary
    }

    @discardableResult open func set(_ value: Data, forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> Bool {
        var queryDictionary: [String: Any] = setupQueryDictionary(forKey: key, withAccessibility: accessibility)
        queryDictionary[secValueData] = value

        if accessibility == nil {
            queryDictionary[secAttrAccessible] = KeychainItemAccessiblity.whenUnlocked.keychainAttrValue
        }

        let status = SecItemAdd(queryDictionary as CFDictionary, nil)
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return update(value, forKey: key, withAccessibility: accessibility)
        } else {
            return false
        }
    }

    @discardableResult open func set(_ value: String, forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return set(data, forKey: key, withAccessibility: accessibility)
    }

    @discardableResult open func set<T>(_ value: T, forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> Bool where T: Numeric, T: Encodable {
        guard let data = try? JSONEncoder().encode([value]) else { return false }
        return set(data, forKey: key, withAccessibility: accessibility)
    }

    @discardableResult open func set<T>(_ value: T, forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> Bool where T: Encodable {
        guard let data = try? JSONEncoder().encode(value) else { return false }
        return set(data, forKey: key, withAccessibility: accessibility)
    }

    /// 更新Item
    ///
    /// - Parameters:
    ///   - value: 数据
    ///   - key: key
    ///   - accessibility:
    /// - Returns: 是否成功
    private func update(_ value: Data, forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> Bool {
        let queryDictionary = setupQueryDictionary(forKey: key, withAccessibility: accessibility)
        let updateDictionary = [secValueData: value]
        let status = SecItemUpdate(queryDictionary as CFDictionary, updateDictionary as CFDictionary)
        return (status == errSecSuccess)
    }

    /// 清空数据
    /// - Warning: 可能把不是通过JJWKeychain添加的Item也清楚掉
    open func wipeKeychain() {
        deleteKeychainSecClass(kSecClassGenericPassword)
        deleteKeychainSecClass(kSecClassInternetPassword)
        deleteKeychainSecClass(kSecClassCertificate)
        deleteKeychainSecClass(kSecClassKey)
        deleteKeychainSecClass(kSecClassIdentity)
    }

    /// 删除某一类的数据
    ///
    /// - Parameter destSecClass: 目标数据类型
    /// - Returns: 删除成功或失败
    @discardableResult private func deleteKeychainSecClass(_ destSecClass: AnyObject) -> Bool {
        let queryDictionary = [secClass: destSecClass]
        let status = SecItemDelete(queryDictionary as CFDictionary)
        return (status == errSecSuccess)
    }

    /// 删除通过JJWKeychainKit添加的item数据
    ///
    /// - Parameters:
    ///   - key: key
    ///   - accessibility:
    /// - Returns: successful is true; fail is false
    @discardableResult open func removeObject(forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> Bool {
        let queryDictionary: [String: Any] = setupQueryDictionary(forKey: key, withAccessibility: accessibility)
        let status = SecItemDelete(queryDictionary as CFDictionary)
        return (status == errSecSuccess)
    }

    /// 删除所有通过JJWKeychainKit添加的数据
    ///
    /// - Returns: success is true； fail is false；
    @discardableResult open func removeAllKeys() -> Bool {
        var queryDictionary: [String: Any] = [secClass: kSecClassGenericPassword]
        queryDictionary[secAttrService] = serviceName
        if let accessGroup = accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup
        }
        let status = SecItemDelete(queryDictionary as CFDictionary)
        return (status == errSecSuccess)
    }

    /// 查询数据
    ///
    /// - Parameters:
    ///   - key: 数据key值
    ///   - accessibility: 数据访问权限
    /// - Returns: Data or nil
    open func data(forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> Data? {
        var queryDictionary = setupQueryDictionary(forKey: key, withAccessibility: accessibility)
        queryDictionary[secMatchLimit] = kSecMatchLimitOne // 只查询一条数据
        queryDictionary[secReturnData] = kCFBooleanTrue // 返回对应数据

        var result: AnyObject?
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &result)
        return (status == errSecSuccess) ? (result as? Data) : nil
    }

    /// 查询string类型的数据，返回string类型
    ///
    /// - Parameters:
    ///   - key: key
    ///   - accessibility: 访问数据权限
    /// - Returns: string or nil
    open func string(forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> String? {
        guard let data = data(forKey: key, withAccessibility: accessibility) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 返回数字类型数据
    ///
    /// - Parameters:
    ///   - type: 数据类型
    ///   - key: key
    ///   - accessibility: 数据访问权限
    /// - Returns: obj or nil
    open func object<T>(of type: T.Type, forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> T? where T: Numeric, T: Decodable {
        guard let data = data(forKey: key, withAccessibility: accessibility) else { return nil }
        return try? JSONDecoder().decode([T].self, from: data)[0]
    }

    /// 返回类型数据
    ///
    /// - Parameters:
    ///   - type: 数据类型
    ///   - key: key
    ///   - accessibility: 数据访问权限
    /// - Returns: obj or nil
    open func object<T>(of type: T.Type, forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> T? where T: Decodable {
        guard let data = data(forKey: key, withAccessibility: accessibility) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// 判断keychain中是否存在某个键
    ///
    /// - Parameters:
    ///   - key: key
    ///   - accessibility: 访问权限能力
    /// - Returns: true or false
    open func hasValue(forKey key: String, withAccessibility accessibility: KeychainItemAccessiblity? = nil) -> Bool {
        if let _ = data(forKey: key, withAccessibility: accessibility) {
            return true
        }
        return false
    }

    /// 查询某个键的访问权限
    ///
    /// - Parameter key: keyStrign
    /// - Returns: 访问能力
    open func accessibilityOfKey(_ key: String) -> KeychainItemAccessiblity? {
        var queryDictionary = setupQueryDictionary(forKey: key)
        queryDictionary[secMatchLimit] = kSecMatchLimitOne
        queryDictionary[secReturnAttributes] = kCFBooleanTrue

        var results: AnyObject?
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &results)

        guard status == errSecSuccess, let dictionary = results as? [String: AnyObject], let accessibility = dictionary[secAttrAccessible] as? String else {
            return nil
        }
        return KeychainItemAccessiblity.accessbilityForAttributeValue(accessibility as CFString)
    }

    /// 获取保存keychain的所有键
    ///
    /// - Returns: 集合<string>
    open func allKeys() -> Set<String> {
        var queryDictionary: [String: Any] = [secClass: kSecClassGenericPassword, secAttrService: serviceName, secReturnAttributes: kCFBooleanTrue!, secMatchLimit: kSecMatchLimitAll]

        if let accessGroup = accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup
        }

        var results: AnyObject?
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &results)
        guard status == errSecSuccess else {
            return []
        }
        var keys = Set<String>()
        if let results = results as? [[String: AnyObject]] {
            keys = results.reduce(into: Set<String>()) { (result: inout Set<String>, attr: [String: AnyObject]) in
                if let accountData = attr[secAttrAccount] as? Data, let key = String(data: accountData, encoding: .utf8) {
                    result.insert(key)
                }
            }
        }
        return keys
    }
}
