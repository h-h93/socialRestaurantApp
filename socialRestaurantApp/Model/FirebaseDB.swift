//
//  UserDB.swift
//  socialRestaurantApp
//
//  Created by hanif hussain on 08/11/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct Friends: Codable {
    var Email: String!
}

struct Restaurants: Codable {
    var email: String!
    var restaurantName: String!
    var restaurantLocation: String!
    var attendingDate: Date!
}

class FirebaseDB {
    var friends = [Friends]()
    weak var delegate: FriendsViewController!
    let storageRef = Firestore.firestore()
    let firestorePath = "Users"
    var restaurants = [Restaurants]()
    var friendsRestaurants = [Restaurants]()
    
    func getFriendsData() {
        guard let auth = Auth.auth().currentUser else { return }
        let userEmail = auth.email!.uppercased()
        
        storageRef.collection("Users/\(userEmail)/Friends").getDocuments() { (querySnapshot, err) in
          if let err = err {
            print("Error getting documents: \(err)")
          } else {
            for document in querySnapshot!.documents {
                let dataDescription = document.data()
                let friendEmail = dataDescription["Email"]! as! String
                let friend = Friends(Email: friendEmail)
                self.friends.append(friend)
            }
              self.delegate.friends = self.friends
              self.getFriendsRestaurants()
          }
        }
//        storageRef.collection(firestorePath).document(userEmail).collection("Friends").getDocuments { snapshot, error in
//            if error == nil && snapshot != nil {
//                let friend = snapshot?.documents.compactMap { document -> Friends? in
//                    return try? document.data(as: Friends.self)
//                }
//                self.friends = friend ?? [Friends]()
//                self.delegate.friends = self.friends
//            }
//            DispatchQueue.main.async {
//                self.delegate.tableView.reloadData()
//            }
//        }
    }
    
    func getFriendsRestaurants() {
        for i in friends {
            storageRef.collection("Users/\(i.Email.uppercased())/Restaurant").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        var restaurant = try? document.data(as: Restaurants.self)
                        if let diff = Calendar.current.dateComponents([.hour], from: restaurant!.attendingDate!, to: Date()).hour, diff > 12 {
                            
                        } else {
                            self.friendsRestaurants.append(restaurant!)
                        }
                    }
                }
                self.delegate.loadFriends(friendsRestaurant: self.friendsRestaurants)
            }
        }
    }
    
    // get a list of restaurants from the DB ( we will only send the latest restaurant from the DB) we need to check if the day == today otherwise it will state the current restaurant the user is visiting is from a previous day.
    func getRestaurant() {
        guard let auth = Auth.auth().currentUser else { return }
        let userEmail = auth.email!.uppercased()
        
        storageRef.collection(firestorePath).document(userEmail).collection("Restaurant").order(by: "attendingDate", descending: true).getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                let restaurant = snapshot?.documents.compactMap { document -> Restaurants? in
                    return try? document.data(as: Restaurants.self)
                }
                self.restaurants = restaurant ?? [Restaurants]()
            }
            NotificationCenter.default.post(name: NSNotification.Name("com.get.restaurantDetails"), object: nil, userInfo: nil)
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            // if there is an error let's handle it
            if let authError = error {
                let err = authError as NSError
                switch err.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    print("Incorrect password")
                case AuthErrorCode.operationNotAllowed.rawValue:
                    print("Sign up, or sign in is disabled for this app")
                case AuthErrorCode.userDisabled.rawValue:
                    print("Account disabled")
                case AuthErrorCode.invalidEmail.rawValue:
                    print("Email invalid, please check if email entered correctly")
                default:
                    print("unknown error \(err.localizedDescription)")
                }
            } else {
                print("user signed in successfully")
                NotificationCenter.default.post(name: NSNotification.Name("com.login.success"), object: nil)
            }
        }
    }
    
    // log user out from our firebase authentication
    func logOut() -> Bool {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: NSNotification.Name("com.user.loggedOut"), object: nil, userInfo: nil)
            return true
        } catch {
            print("Sign out error")
            return false
        }
    }
    
    // crete a new user in the DB
    func createNewUser(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email.uppercased(), password: password) { authDataResult, error in
            // if there is an error let's handle it
            if let authError = error {
                let err = authError as NSError
                switch err.code {
                case AuthErrorCode.weakPassword.rawValue:
                    print("Weak password unable to create account")
                case AuthErrorCode.operationNotAllowed.rawValue:
                    print("Sign up, or sign in is disabled for this app")
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    print("Email already in use")
                case AuthErrorCode.invalidEmail.rawValue:
                    print("Email invalid, please check if email entered correctly")
                case AuthErrorCode.weakPassword.rawValue:
                    print("Weak password")
                default:
                    print("unknown error \(err.localizedDescription)")
                }
            } else {
                print("user signed up successfully")
                self.createInitialUserEntry()
                let newuserInfo = Auth.auth().currentUser
                NotificationCenter.default.post(name: NSNotification.Name("com.login.success"), object: nil)
            }
        }
    }
    
    func createInitialUserEntry() {
        do {
            storageRef.collection("Users").document("\(Auth.auth().currentUser!.email!.uppercased())").collection("Creation").document("Created").setData(["Created" : ""])
        } catch {
            
        }
    }
    
    // upload the restaurant the user is going to
    func uploadRestaurant(restaurant: Restaurants) {
        guard let auth = Auth.auth().currentUser else { return }
        let userEmail = auth.email!.uppercased()
        do {
            try
            storageRef.collection(firestorePath).document(userEmail).collection("Restaurant").document(UUID().uuidString).setData(from: restaurant)
        } catch {
            
        }
    }
    
    // upload users friends list in DB
    func uploadFriends(email: String) {
        
        let docRef = storageRef.collection(firestorePath).document(email).collection("Creation").document("Created")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // Check if the field exists in data
                self.storageRef.collection(self.firestorePath).document(Auth.auth().currentUser!.email!.uppercased()).collection("Friends").addDocument(data: ["Email" : email])
                self.delegate.friends.append(Friends(Email: email))
                DispatchQueue.main.async {
                    self.delegate.tableView.reloadData()
                }
                print("Exists")
            } else {
                print("Document does not exist")
            }
        }
        
//        let docRef = storageRef.collection(firestorePath).document(email)
//        //print(Auth.auth().currentUser?.email?.uppercased())
//        // Force the SDK to fetch the document from the cache. Could also specify
//        // FirestoreSource.server or FirestoreSource.default.
//        docRef.getDocument(source: .server) { (document, error) in
//          if let document = document {
//              let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//              if dataDescription != "nil" {
//                  self.storageRef.collection(self.firestorePath).document(Auth.auth().currentUser!.email!.uppercased()).collection("Friends").addDocument(data: ["Email" : email])
//                  print("Does not exist: \(document.documentID)")
//              }
//          } else {
//            print("User exists")
//          }
//        }
    }
    
    // delete restaurant from DB
    func deleteRestaurant() {
        
    }
}
