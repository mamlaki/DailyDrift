//
//  AuthenticationManager.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-26.
//

import LocalAuthentication

class AuthenticationManager {
    func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Entry") { success, authError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            print("Cannot evalute policy: \(error?.localizedDescription ?? "Unknown error")")
            completion(false)
        }
    }
}
