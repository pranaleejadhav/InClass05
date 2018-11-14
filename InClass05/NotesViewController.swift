//
//  NotesViewController.swift
//  InClass05
//
//  Created by Pranalee Jadhav on 11/9/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class customCell: UITableViewCell {
    
    @IBOutlet weak var datetime: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    
}

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tableArr = [Notebook]()//[Dictionary<String,String>]()
    var notebookid:String!
    var refNotes:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(notebookid)
        refNotes = Database.database().reference().child("notes").child(Auth.auth().currentUser!.uid).child(notebookid)
        
        self.title = "Notes"
        /*var backBtn: UIButton!
        backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 25))
        backBtn.setTitle("Logout", for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(logout), for: .touchUpInside)
        backBtn.contentHorizontalAlignment = .left
        backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        backBtn.setTitleColor(.blue, for: UIControlState.normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        */
        
        var rightBtn: UIButton!
        rightBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 25))
        rightBtn.setImage(UIImage(named: "add.png"), for: UIControlState.normal)
        rightBtn.addTarget(self, action: #selector(addNote(_:)), for: .touchUpInside)
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        rightBtn.tintColor = .blue
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        
        tableView.separatorColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        getData()
        
    }
    
    @IBAction func addNote(_ sender: Any) {
        //building an alert
        let alertController = UIAlertController(title: "New Note", message: "Enter New Post Text", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            
            //getting new values
            let name = alertController.textFields?[0].text
            
            //calling the update method to update artist
            
            if name != "" {
                self.addData(title: name!)
            } else {
                self.showMsg(title: "", subTitle: "Post cannot be empty.")
            }
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding two textfields to alert
        alertController.addTextField { (textField) in
            textField.placeholder = "Note text"
        }
        
        
        //adding action
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //presenting dialog
        present(alertController, animated: true, completion: nil)
    }
    
    func getData() {
        //observing the data changes
        refNotes.observe(DataEventType.value, with: { (snapshot) in
            
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                
                //clearing the list
                self.tableArr.removeAll()
                
                //iterating through all the values
                for note in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let noteObj = note.value as? [String: AnyObject]
                    let name  = noteObj?["name"]
                    let id  = noteObj?["id"]
                    let created_date = noteObj?["created_date"]
                    
                    //creating notebook object with model and fetched values
                    let artist = Notebook(id: id as! String?, name: name as! String?, created_date: created_date as! String?)
                    
                    //appending it to list
                    self.tableArr.append(artist)
                }
                
                self.tableArr.reverse()
                
                //reloading the tableview
                self.tableView.reloadData()
            }
        })
    }
    
    func addData(title: String) {
        let key = refNotes.childByAutoId().key
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        
        
        //creating notebook with the given values
        let note = ["id":key,
                        "name": title as String,
                        "created_date": dateFormatter.string(from: Date())
        ]
        
        //adding the notebook inside the generated unique key
        refNotes.child(key!).setValue(note)
        showMsg(title: "", subTitle: "Note created!")
    }
    
    @objc func deleteData(sender: UIButton!) {
        let btn: UIButton = sender
        
        refNotes.child(tableArr[btn.tag].id!).removeValue()
        showMsg(title: "", subTitle: "Post Deleted!")
    }

    // MARK: - TableView Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableArr.count
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellItem")  as!  customCell  //1.
        cell.detail.text = tableArr[indexPath.row].name
        cell.datetime.text = "Created On " + tableArr[indexPath.row].created_date!
        cell.deleteBtn.addTarget(self, action: #selector(self.deleteData), for: .touchUpInside)
        cell.deleteBtn.tag = indexPath.row
        
        return cell
        
    }
    
   /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }*/
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableArr.count == 0 {
            
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
            label.text = "No Note created."
            label.textAlignment = .center
            label.textColor = #colorLiteral(red: 0.1765674055, green: 0.4210852385, blue: 0.8841049075, alpha: 1)
            footerView.addSubview(label)
            return footerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableArr.count == 0 {
            return 80
        } else {
            return 0
        }
    }

    
    func showMsg(title: String, subTitle: String) -> Void {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message:
                subTitle, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        })
    }
}
