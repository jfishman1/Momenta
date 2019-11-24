//
//  DataModel.swift
//  humble
//
//  Created by Jonathon Fishman on 10/27/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import Foundation
import Firebase

protocol ProfileDataModelDelegate: class {
    func didReceiveProfileDataUpdate(posts: [Post], comments: [Comment])
}

class ProfileDataModel {
    weak var delegate: ProfileDataModelDelegate?
    var postIds = [String]()
    var commentIds = [String]()
    
    func requestProfilePostAndCommentData() {
        if postIds.count != 0 && commentIds.count != 0 {
            fetchPosts(completion: { posts in
                self.fetchComments(completion: { comments in
                    self.delegate?.didReceiveProfileDataUpdate(posts: posts, comments: comments)
                })
            })
        } else if postIds.count != 0 && commentIds.count == 0 {
            fetchPosts(completion: { posts in
                self.delegate?.didReceiveProfileDataUpdate(posts: posts, comments: [])
            })
        } else if postIds.count == 0 && commentIds.count != 0 {
            fetchComments(completion: { comments in
                self.delegate?.didReceiveProfileDataUpdate(posts: [], comments: comments)
            })
        } else {
            self.delegate?.didReceiveProfileDataUpdate(posts: [], comments: [])
        }
    }
    
    private func fetchPosts(completion: @escaping ([Post])->()) {
        var posts = [Post]()
        posts.removeAll()
        for postId in postIds {
            Cloud.sharedInstance.fetchPostById(postId: postId, completion: { post in
                if post.postDescription! != "" {
                    posts.append(post)
                }
                //print("ProfileDataModel posts.count: ", posts.count)
                completion(posts)
            })
        }
    }
    
    private func fetchComments(completion: @escaping ([Comment])->()) {
        var comments = [Comment]()
        comments.removeAll()
        for commentId in commentIds {
            Cloud.sharedInstance.fetchCommentById(commentId: commentId, completion: { comment in
                comments.append(comment)
                //print("ProfileDataModel comments.count: ", comments.count)
                completion(comments)
            })
        }
    }
}

//-------------------------------------

protocol PostDataModelDelegate: class {
    func didReceivePostDataUpdate(post: Post, comments: [Comment])
}

class PostDataModel {
    weak var delegate: PostDataModelDelegate?
    
    var postId: String?
    var comments = [Comment]()
    var reportedCommentIds = [String]()

    func requestPostData() {
        guard let postId = self.postId else {
            print("Could not get postId")
            return
        }
        Cloud.sharedInstance.fetchReportedCommentIds(postId: postId, completion: { commentIds in
            self.reportedCommentIds.removeAll()
            self.reportedCommentIds = commentIds
        }, err: { error in
            print("error: ", error.localizedDescription)
        })
        Cloud.sharedInstance.fetchCommentIds(postId: postId, completion: { commentIds in
            //print("commentIds.count: ", commentIds.count)
            self.comments.removeAll()
            for commentId in commentIds {
                if !self.reportedCommentIds.contains(commentId) {
                    Cloud.sharedInstance.fetchCommentById(commentId: commentId, completion: { comment in
                        self.comments.append(comment)
                    })
                }
            }
            Cloud.sharedInstance.fetchPostById(postId: postId, completion: { post in
                self.delegate?.didReceivePostDataUpdate(post: post, comments: self.comments)
            })
        }, err: { error in
            print("error: ", error.localizedDescription)
        })
    }
}








