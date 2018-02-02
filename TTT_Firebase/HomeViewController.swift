//
//  HomeViewController.swift
//  TTT_Firebase
//
//  Created by jrhilke on 1/28/18.
//  Copyright © 2018 Hilke Applications. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON

class HomeViewController: UIViewController
{
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    var userName:String?
    var noOpponents:Bool?
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    //determine whether to take the user to the Game View
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let username = userNameTextField.text!
        return ((username != "") ) //&& unmatchedUsersExists()) //Only perform segue if the user has entered a username and there is a waiting player
    }

    
    @IBAction func startGameButtonPressed(_ sender: Any)
    {
        //print(unmatchedUsersExists())
        
        if userNameTextField.text == "" //no username entered
        {
            // create the alert
            let alert = UIAlertController(title: nil, message: "Username required", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
//        else if !unmatchedUsersExists() //no available oppenents
//        {
//            let alert = UIAlertController(title: nil, message: "No available opponents at this time", preferredStyle: UIAlertControllerStyle.alert)
//
//            // add an action (button)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//
//            // show the alert
//            self.present(alert, animated: true, completion: nil)
//
//            let username = userNameTextField.text!
//            signIn(withUserName: username)
//            let userID = FIRAuth.auth()?.currentUser!.uid
//            ref.child("Unmatched_Users").child(userID!).setValue(["username": username])
//        }
            
       
       
//            var activityIndicator = UIActivityIndicatorView()
//            activityIndicator.center = self.view.center
//            activityIndicator.hidesWhenStopped = true
//            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            view.addSubview(activityIndicator)
//            activityIndicator.startAnimating()
        
        else{
            userName = userNameTextField.text!
            signIn(withUserName: userName!)
            let userID = FIRAuth.auth()?.currentUser!.uid
            matchIfPossible{ (wasMatched) in
                if !wasMatched { //if there are no waiting players
                    
                    
                    // create the alert
                    let alert = UIAlertController(title: nil, message: "No available opponents", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    
    
    func signIn(withUserName name:String)
    {
        FIRAuth.auth()?.signInAnonymously() { (user,error) in
            if error == nil {
                print("\(name) is logged in with uid \(user!.uid)")
            }
            else{
                print(error)
                return
            }
        }
    }
    
    func matchIfPossible(completion: @escaping ((Bool) -> Void)) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("Unmatched_Users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let json = snapshot.json
            let currentUserID = (FIRAuth.auth()?.currentUser?.uid)!
            let currentUserName = self.userName
            if json.count > 0 { // we can match these two
            
                for (objectId, user) in json {
                    print(user)
                    let matchedUserName = user["username"].stringValue
                    let matchedUserID = objectId
                    let gameData = ["x-player": currentUserName, "o-player": matchedUserName, "status": "active", "gameBoard": [0,0,0,0,0,0,0,0,0], "winner": "none" ] as [String : Any]
                    
                    ref.child("Matches").setValue([currentUserID + "-" + matchedUserID : ["gameData": gameData]])
                    ref.child("Unmatched_Users").child(objectId).removeValue()
                    completion(true)
                    break // we finished matching, so break out of the loop
                }
            } else { // add this guy to unmatched
                ref.child("Unmatched_Users").child(currentUserID).setValue(["username": currentUserName])
                completion(false)
            }
        })
        
        
    }
    
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Helpers

//    func getUnmatchedUsers(@escaping completionHandler: @escaping ((JSON) -> Void)) {
//        ref.child("Unmatched_Users").observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.hasChildren() {
//                var json = snapshot.json
//                completionHandler(response)
//            }
//        })
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension FIRDataSnapshot  {
    var json: JSON {
        return JSON(self.value!)
    }
}
