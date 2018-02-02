//
//  GameViewController.swift
//  TTT_Firebase
//
//  Created by jrhilke on 1/28/18.
//  Copyright © 2018 Hilke Applications. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class GameViewController: UIViewController {
     
    @IBOutlet weak var opponentLabel: UILabel!
    
    
    var activePlayer = 1 //Cross
    var ref: FIRDatabaseReference?
    var gameBoard = [0,0,0,0,0,0,0,0,0]
    var gameIsActive: Bool = true
    var winningPlayer: Int? = nil //is 1 if X wins, 2 if O wins
    
    override func viewDidLoad() {
        opponentLabel.text = "Opponent: "
        ref = FIRDatabase.database().reference()
        super.viewDidLoad()
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        
    }
    
    @IBAction func piecePlaced(_ sender: AnyObject) {
        if (gameBoard[sender.tag] == 0) && gameIsActive
        {
            
              gameBoard[sender.tag] = activePlayer
            
            if (activePlayer == 1)
            {
                (sender as AnyObject).setImage(UIImage(named: "x.png"), for: UIControlState())
                activePlayer = 2
               
            }
                
            else
            {
                (sender as AnyObject).setImage(UIImage(named: "o.jpg"), for: UIControlState())
                activePlayer = 1
            }
            
             isGameOver()        }
        
       
    }
    
    func updateGameBoard(withIndex index: Int, andActivePlayer activePlayer: Int){
        
    }
    
    func isGameOver() -> Bool {
        let winningPlacements = [ [0,1,2], [0,3,6], [3,4,5], [6,7,8], [1,4,7], [2,5,8], [0,4,8], [2,4,6] ]

        for placement in winningPlacements{
            if gameBoard[placement[0]] != 0 && gameBoard[placement[0]] == gameBoard[placement[1]] && gameBoard[placement[1]] == gameBoard[placement[2]]{
                gameIsActive = false
                var winner = ""
                if gameBoard[placement[0]] == 1{
                    winner = "X"
                } else{
                    winner = "Y"
                }
                
                // create the alert
                let alert = UIAlertController(title: nil, message: "\(winner) wins!", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                
                return true
            }
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
