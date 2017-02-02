//
//  DataService.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 1/30/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let KEY_UID = "uid"

class DataService {
    static let ds = DataService()
    
    fileprivate var _REF_BASE = DB_BASE
    fileprivate var _REF_USERS = DB_BASE.child("users")
    fileprivate var _REF_INGREDIENTS = DB_BASE.child("ingredients")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_CURRENT_USER: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_INGREDIENTS: FIRDatabaseReference {
        return _REF_INGREDIENTS
    }
    
    func createFirebaseDBUser(_ uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func completeSignIn(_ id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(id, userData: userData)
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
    }
}
