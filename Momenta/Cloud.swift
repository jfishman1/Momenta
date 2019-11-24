//
//  Cloud.swift
//  humble
//
//  Created by Jonathon Fishman on 10/5/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import Foundation

import Firebase
import GoogleSignIn
import FacebookLogin
import FBSDKLoginKit
import TwitterKit

class Cloud {
    
    static let sharedInstance = Cloud()
    private init() {}
    
    func initApp() {
        // Init Firebase
        FirebaseApp.configure()
    }
    
    // MARK: LOGIN / OUT
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    func setGIDSignInClass() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
         //Client ID inside GoogleService-Info.plish
        // Added Reversed Client ID to App Target > Info > URL Types > URL Schemes
        // Video (not docs) said to add Bundle ID another URL Types > URL Schemes
    }
    
    func loginWithGoogle(authentication: GIDAuthentication, completion: @escaping (String, [String: AnyObject]) -> (), err: @escaping (Error)->()) {
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential, completion: {(authResult, error) in
            if error != nil {
                //print("Google Sign In error: ", error!.localizedDescription)
                err(error!)
            } else if authResult != nil {
                let uid = authResult!.user.uid
                let firstName = authResult!.user.displayName ?? ""
                let lastName = ""
                let email = authResult!.user.email
                let profileImageUrl = authResult!.user.photoURL!.absoluteString
                let values: [String: AnyObject] = ["firstName": firstName as AnyObject, "lastName": lastName as AnyObject, "email": email as AnyObject, "userId": uid as AnyObject, "bigProfileImageUrl": profileImageUrl as AnyObject, "smallProfileImageUrl": profileImageUrl as AnyObject]
                completion(uid, values)
            } else {
                return
            }
        })
    }
    
    func loginWithFacebook(viewController: UIViewController, completion: @escaping (String, [String: AnyObject]) -> (), err: @escaping (Error)->()) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.email, .publicProfile], viewController: viewController, completion: { (loginResult) in
            switch loginResult {
            case .failed(let error):
                err(error)
            case .cancelled:
                print("User cancelled login.")
            case .success://(let grantedPermissions, let declinedPermissions, let accessToken):
                //print("grantedPermissions: ", grantedPermissions)
                //print("declinedPermissions: ", declinedPermissions)
                //print("accessToken: ", accessToken)
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)// current().tokenString)
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    if let error = error {
                        err(error)
                    } else if authResult != nil {
                        //print("user.debugDescription: ", user.debugDescription)
                        let uid = authResult!.user.uid
                        //print("uid: ", uid)
                        let firstName = authResult!.user.displayName ?? ""
                        //print("firstName: ", firstName)
                        let lastName = ""
                        let email = authResult!.user.email
                        let profileImageUrl = authResult!.user.photoURL!.absoluteString
                        //print("profileImageUrl: ", profileImageUrl)
                        let values: [String: AnyObject] = ["firstName": firstName as AnyObject, "lastName": lastName as AnyObject, "email": email as AnyObject, "userId": uid as AnyObject, "bigProfileImageUrl": profileImageUrl as AnyObject, "smallProfileImageUrl": profileImageUrl as AnyObject]
                        completion(uid, values)
                    } else {
                        err(error!)
                    }
                }
            }
        })
    }
    
    func loginWithTwitter(viewController: UIViewController, completion: @escaping (String, [String: AnyObject]) -> (), err: @escaping (Error) -> ()) {
        TWTRTwitter.sharedInstance().logIn(with: viewController, completion: { (session, error) in
            if error != nil {
                err(error!)
            } else {
                guard let token = session?.authToken else { return }
                guard let secret = session?.authTokenSecret else { return }
                let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
                let client = TWTRAPIClient.withCurrentUser()
                client.requestEmail { email, error in
                    if (email != nil) {
                        Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) in
                            if error != nil {
                                err(error!)
                            } else {
                                let uid = authResult!.user.uid
                                let firstName = authResult!.user.displayName ?? ""
                                let lastName = ""
                                let email = email
                                let profileImageUrl = authResult!.user.photoURL!.absoluteString
                                let values: [String: AnyObject] = ["firstName": firstName as AnyObject, "lastName": lastName as AnyObject, "email": email as AnyObject, "userId": uid as AnyObject, "bigProfileImageUrl": profileImageUrl as AnyObject, "smallProfileImageUrl": profileImageUrl as AnyObject]
                                completion(uid, values)
                            }
                        })
                    } else {
                        err(error!)
                    }
                }
            }
        })
    }
    
    func loginWithEmail(email: String, password: String, completion: @escaping (String) -> (), err: @escaping (Error) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (authResult, error) in
            let currentUserId: String!
            if error != nil {
                err(error!)
                return
            }
            if authResult != nil {
                currentUserId = authResult!.user.uid
                completion(currentUserId)
            }
        })
    }
    
    func createUserWithEmail(email: String, password: String, firstName: String, lastName: String, completion: @escaping (String, [String: AnyObject]) -> (), err: @escaping (Error)->()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (authResult, error) in
            if error != nil {
                err(error!)
                return
            }
            let uid = authResult!.user.uid
            let values: [String: AnyObject] = ["firstName": firstName as AnyObject, "lastName": lastName as AnyObject, "email": email as AnyObject, "userId": uid as AnyObject, "smallProfileImageUrl": "" as AnyObject]
            completion(uid, values)
        })
    }
    
    // userID Token different from userID
    func getUserIDToken( completion: @escaping (String?) -> ()) {
        // Detect if user is logged in already and go to main tab bar controller, Launch Screen might take care of login controller flash
        Auth.auth().currentUser?.getIDToken(completion: { auth, error in
            if error != nil {
                print("error getting UserID Token: ", error as Any)
            } else {
                completion(auth)
            }
        })
    }
    
    func cacheLogginStatus(completion: @escaping (Bool)->()) {
        var isUserLoggedIn: Bool
        if let userLoginSatus = Utility.sharedInstance.loadUserLogginStatusFromArchiver() {
            if userLoginSatus == true {
                isUserLoggedIn = true
                completion(isUserLoggedIn)
            } else {
                isUserLoggedIn = false
                completion(isUserLoggedIn)
            }
        } else {
            if Auth.auth().currentUser?.uid == nil {
                isUserLoggedIn = false
                Utility.sharedInstance.writeUserLogginStatus(isLoggedIn: isUserLoggedIn)
                completion(isUserLoggedIn)
            } else {
                isUserLoggedIn = true
                Utility.sharedInstance.writeUserLogginStatus(isLoggedIn: isUserLoggedIn)
                completion(isUserLoggedIn)
            }
        }
    }
    
    func getCurrentUserId(completion:@escaping (String?) -> ()) {
        if let user = Auth.auth().currentUser {
            let userId = user.uid
            completion(userId)
        }
    }
    
    // MARK: Users
    
    func updateUserInDatabaseWithUID(uid: String, values: [String: AnyObject], completion: @escaping() ->()) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                return
            }
            completion()
        })
    }
    
    func setupNameAndProfileImage(message: Message, completion: @escaping (_ name: String, _ profileImageUrl: String) -> ()) {
        if let id = message.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    let firstName = dictionary["firstName"] as? String ?? ""
                    let lastName = dictionary["lastName"] as? String ?? ""
                    let name = "\(firstName) \(lastName)"
                    let profileImageUrl = dictionary["smallProfileImageUrl"] as? String ?? ""
                    completion(name, profileImageUrl)
                }
            }, withCancel: nil)
        }
    }
    
    func fetchCurrentUserSupporters(uid: String, completion: @escaping (User)->()) {
        let userSupportersRef = Database.database().reference().child("users").child(uid).child("supporters")
        userSupportersRef.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            self.fetchUserData(userId: userId, completion: { user in
                completion(user)
            }, err: { return })
        })
    }
    
    func fetchUserData(userId: String, completion: @escaping (User) -> (), err: @escaping ()->()) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let userDictionary = snapshot.value as? [String: AnyObject] {
                let user = User(userDictionary: userDictionary)
                completion(user)
            } else {
                err()
            }
        }, withCancel: { _ in
            err()
        })
    }
    
    func fetchBlockedUserIds(uid: String, completion: @escaping (String) -> ()) {
        let blockedUsersRef = Database.database().reference().child("users").child(uid).child("blockedUsers")
        blockedUsersRef.observe(.childAdded, with: { (snapshot) in
            //print(snapshot)
            let blockedUserId = snapshot.key
            completion(blockedUserId)
        })
    }
    
    func addSupporterToPostCreator(postCreatorId: String, currentUserId: String, completion: @escaping ()->()) {
        let postCreatorSupportersRef = Database.database().reference().child("users").child(postCreatorId).child("supporters")
        postCreatorSupportersRef.updateChildValues([currentUserId:1])
        completion()
    }
    
    func addSupporterToGroup(postId: String, currentUserId: String, completion: @escaping ()->()) {
        let currentUserGroupsRef = Database.database().reference().child("users").child(currentUserId).child("groups")
        currentUserGroupsRef.updateChildValues([postId:1])
        completion()
    }
    
    func blockUser(currentUserId: String, blockedUserId: String, completion: @escaping ()->()) {
        let currentUserBlockRef = Database.database().reference().child("users").child(currentUserId).child("blockedUsers")
        currentUserBlockRef.updateChildValues([blockedUserId:1])
        completion()
    }
    
    
    // MARK: Posts
    
    func fetchAllPostsData(completion: @escaping (Post) -> (), err: @escaping (Error)->()) {
        let postsReference = Database.database().reference().child("posts")
        postsReference.observe(.childAdded, with: { (snapshot) in
            postsReference.removeAllObservers()
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let post = Post(postDictionary: dictionary)
                completion(post)
                //postsReference.removeAllObservers()
            }
        }, withCancel: { (error) in
            err(error)
        })
    }
    
    func fetchReportedPostIds(completion: @escaping (String) -> (), err: @escaping (Error)->()) {
        let postsReference = Database.database().reference().child("reported-posts")
        postsReference.observe(.childAdded, with: { (snapshot) in
            postsReference.removeAllObservers()
            let postId = snapshot.key
            completion(postId)
        }, withCancel: { (error) in
            err(error)
        })
    }
    
    func fetchReportedCommentIds(postId: String, completion: @escaping ([String]) -> (), err: @escaping (Error)->()) {
        let reference = Database.database().reference().child("reported-comments").child(postId)
        reference.observe(.value, with: { (snapshot) in
            if let commentsDictionary = snapshot.value as? [String: AnyObject] {
                var commentIds = [String]()
                for commentId in commentsDictionary.keys {
                    commentIds.append(commentId)
                }
                completion(commentIds)
            }
            else {
                completion([])
            }
        }, withCancel: nil
        )
    }
    
    func fetchPostById(postId: String, completion: @escaping (Post) -> ()) {
        let postIdRef = Database.database().reference().child("posts").child(postId)
        //postIdRef.observeSingleEvent(of: .value, with: {(snapshot) in
        postIdRef.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let post = Post(postDictionary: dictionary)
            postIdRef.removeAllObservers()
            completion(post)
        }, withCancel: nil)
    }
    
    func updatePostSupporters(postId: String, supporterId: String, completion: @escaping ()->()) {
        let postSupportersRef = Database.database().reference().child("posts").child(postId).child("supporterIds")
        postSupportersRef.updateChildValues([supporterId:1])
        completion()
    }
    
    func reportPost(postId: String, postCreatorName: String, reporterId: String, completion: @escaping () ->()) {
        let reportRef = Database.database().reference().child("reported-posts").child(postId)
        let values: [String: AnyObject] = ["postCreatorName": postCreatorName as AnyObject, "reporterId": reporterId as AnyObject]
        reportRef.updateChildValues(values)
        completion()
    }
    
    func reportComment(postId: String, commentId: String, commentCreatorName: String, reporterId: String, completion: @escaping () ->()) {
        let reportRef = Database.database().reference().child("reported-comments").child(postId).child(commentId)
        let values: [String: AnyObject] = ["commentCreatorName": commentCreatorName as AnyObject, "reporterId": reporterId as AnyObject]
        reportRef.updateChildValues(values)
        completion()
    }
    
    
    
    // MARK: Post-comments
    
    func fetchCommentIds(postId: String, completion: @escaping ([String])->(), err: @escaping (Error)->()) {
        let commentsRef = Database.database().reference().child("post-comments").child(postId)
        //commentsRef.observeSingleEvent(of: .value, with: { (snapshot) in // removed to update detailviewmodel
        commentsRef.observe(.value, with: { (snapshot) in
            if let commentsDictionary = snapshot.value as? [String: AnyObject] {
                var commentIds = [String]()
                for commentId in commentsDictionary.keys {
                    commentIds.append(commentId)
                }
                completion(commentIds)
            }
            else {
                completion([])
            }
        }, withCancel: nil
        )
    }
    
    // MARK: Comments
    
    func fetchCommentById(commentId: String, completion: @escaping (Comment) ->()) {
        let commentIdRef = Database.database().reference().child("comments").child(commentId)
        //commentRef.observeSingleEvent(of: .value, with: { (snapshot) in // removed to update detailviewmodel
        commentIdRef.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let comment = Comment(commentDictionary: dictionary)
            completion(comment)
        }, withCancel: { error in
        })
    }
    
    
    
    
    // MARK: Image Storage
    enum FirebaseStorageFilePaths: String {
        case message_images = "message_images"
        case message_movies = "message_movies"
        case post_images = "post_images"
        case post_movies = "post_movies"
        case comment_images = "comment_images"
    }
    
    func uploadMovieToFirebaseStorage(url: URL, filePath: FirebaseStorageFilePaths, completion: @escaping([String: AnyObject]) -> (), err: @escaping(Error) ->()) {
        let filename = UUID().uuidString + ".mov"
        let storageRef = Storage.storage().reference().child(filePath.rawValue).child(filename)
        storageRef.putFile(from: url, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                err(error!)
                return
            }
            storageRef.downloadURL(completion: { (videoUrl, error) in
                if error != nil {
                    return
                }
                let videoUrl = videoUrl?.absoluteString
                if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                    Cloud.sharedInstance.uploadImageToFirebaseStorage(image: thumbnailImage, filePath: .message_images, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        completion(properties)
                    }, err: { error in
                        err(error)
                    })
                }
            })
        })
//        uploadTask.observe(.progress) { (snapshot) in
//            if let completedUnitCount = snapshot.progress?.completedUnitCount {
//                if let totalUnitCount = snapshot.progress?.totalUnitCount {
//                    print("\(String(completedUnitCount)) / \(String(totalUnitCount))")
//                }
//            }
//        }
//        uploadTask.observe(.success) { (snapshot) in
//            //self.navigationItem.title = self.user?.firstName
//            uploadTask.removeAllObservers()
//        }
    }
    
    fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, filePath: FirebaseStorageFilePaths, completion: @escaping (_ imageUrl: String) -> (), err: @escaping (Error) -> ()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child(filePath.rawValue).child("\(imageName).jpg")
        
        if let uploadData = image.jpegData(compressionQuality: 0.8) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    err(error!)
                }
                ref.downloadURL(completion: { (imageUrl, error) in
                    if let imageUrl = imageUrl?.absoluteString {
                        completion(imageUrl)
                    }
                })
            })
        }
    }
    
    func uploadPostImageWithNameToFirebaseStorage(_ image: UIImage, imageName: String, postId: String, completion: @escaping () -> ()) {
        //let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("post_images").child("\(imageName).jpg")
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                ref.downloadURL(completion: { (imageUrl, error) in
                    if let imageUrl = imageUrl?.absoluteString {
                        //completion(imageUrl)
                        let postRef = Database.database().reference().child("posts").child(postId)
                        let values: [String: AnyObject] = ["postImageUrl": imageUrl as AnyObject]
                        postRef.updateChildValues(values)
                        completion()
                    }
                })
            })
        }
    }
    
    func uploadCommentImageWithNameToFirebaseStorage(_ image: UIImage, filePath: FirebaseStorageFilePaths, imageName: String, commentId: String, completion: @escaping () -> ()) {
        //let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child(filePath.rawValue).child("\(imageName)")
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                ref.downloadURL(completion: { (imageUrl, error) in
                    if let imageUrl = imageUrl?.absoluteString {
                        //completion(imageUrl)
                        let postRef = Database.database().reference().child("comments").child(commentId)
                        let values: [String: AnyObject] = ["commentImageUrl": imageUrl as AnyObject]
                        postRef.updateChildValues(values)
                        completion()
                    }
                })
            })
        }
    }
    
    func saveUserProfileImages(uid: String, bigImageName: String, smallImageName: String, bigUploadData: Data, smallUploadData: Data, completion: @escaping()->()) {
        let bigStorageRef = Storage.storage().reference().child("big_profile_images").child("\(bigImageName).jpg")
        let smallStorageRef = Storage.storage().reference().child("small_profile_images").child("\(smallImageName).jpg")
        bigStorageRef.putData(bigUploadData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print(error)
                return
            }
            bigStorageRef.downloadURL(completion: { (bigProfileImageUrl, error) in
                if let bigProfileImageUrl = bigProfileImageUrl?.absoluteString {
                    smallStorageRef.putData(smallUploadData, metadata: nil, completion: { (metadata, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        smallStorageRef.downloadURL(completion: { (smallProfileImageUrl, error) in
                            if let smallProfileImageUrl = smallProfileImageUrl?.absoluteString {
                                let values = ["bigProfileImageUrl": bigProfileImageUrl as AnyObject, "smallProfileImageUrl": smallProfileImageUrl as AnyObject]
                                self.updateUserInDatabaseWithUID(uid: uid, values: values as [String : AnyObject], completion: {  completion() })
                            }
                        })
                    })
                }
            })
            
        })
    }
    
}
