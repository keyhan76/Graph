//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Keyhan on 12/6/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var username: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}

extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print("Error \(error)")
        } else {
            guard let authentication = user.authentication else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { [unowned self] (user, error) in
                if let error = error {
                    print("Error \(error)")
                    return
                }
                let name = user?.additionalUserInfo?.profile?["name"] as? String
                // Save user's name based on its Google profile
                DataService.shared.name = name
                DataService.shared.id = user?.user.uid
                let user = Users(name: DataService.shared.name ?? "No name", id: user?.user.uid ?? "", username: self.username)
                print(user.representation)
                DataService.shared.createUser(user: user)
            }
        }
    }
}
