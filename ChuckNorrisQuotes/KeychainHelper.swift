//
//  KeychainHelper.swift
//  ChuckNorrisQuotes
//
//  Created by Дмитрий Дудник on 18.09.2025.
//

import Foundation
import Security

enum KeychainHelper {
    static func saveKey(_ key: Data, for keyName: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyName,
            kSecValueData as String: key
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func loadKey(for keyName: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else { return nil }
        return item as? Data
    }
}
