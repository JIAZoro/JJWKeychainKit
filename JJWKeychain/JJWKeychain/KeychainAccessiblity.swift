//
//  KeychainAccessiblity.swift
//  JJWKeychain
//
//  Created by mrjia on 2019/10/11.
//  Copyright © 2019 norchant. All rights reserved.
//

import Foundation

public enum KeychainItemAccessiblity {
    case afterFirstUnlock
    case afterFirstUnlockThisDeviceOnly
    case whenPasscodeSetThisDeviceOnly
    case whenUnlocked
    case whenUnlockedThisDeviceOnly

    static func accessbilityForAttributeValue(_ keychainAttrValue: CFString) -> KeychainItemAccessiblity? {
        for (key, value) in keychainAccessiblityLookup {
            if value == keychainAttrValue {
                return key
            }
        }
        return nil
    }
}

private let keychainAccessiblityLookup: [KeychainItemAccessiblity: CFString] = [
    .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock,
    .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    .whenPasscodeSetThisDeviceOnly: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
    .whenUnlocked: kSecAttrAccessibleWhenUnlocked,
    .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
]

protocol KeychainAttrRepentable {
    var keychainAttrValue: CFString { get }
}

extension KeychainItemAccessiblity: KeychainAttrRepentable {
    var keychainAttrValue: CFString {
        return keychainAccessiblityLookup[self]!
    }
}
