//
//  AppDelegate.swift
//  ChuckNorrisQuotes
//
//  Created by Дмитрий Дудник on 02.09.2025.
//

import UIKit
import RealmSwift
import Security

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let keychainKey = "realmEncryptionKey"

        var key: Data
        if let savedKey = KeychainHelper.loadKey(for: keychainKey) {
            key = savedKey
        } else {
            key = Data(count: 64)
            _ = key.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, 64, $0.baseAddress!)
            }
            KeychainHelper.saveKey(key, for: keychainKey)
        }

        let config = Realm.Configuration(encryptionKey: key)
        Realm.Configuration.defaultConfiguration = config

        do {
            _ = try Realm()
            print("Realm успешно открыт с шифрованием")
        } catch {
            print("Ошибка открытия Realm: \(error)")
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

