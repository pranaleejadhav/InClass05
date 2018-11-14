//
//  NoteBookViewController.swift
//  InClass05
//
//  Created by Pranalee Jadhav on 11/9/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NoteBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tableArr = [Notebook]()//[Dictionary<String,String>]()
    
    
    var refNoteBook = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
        .child("notebooks")
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Note Books"
        var backBtn: UIButton!
        backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 25))
        backBtn.setTitle("Logout", for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(logout), for: .touchUpInside)
        backBtn.contentHorizontalAlignment = .left
        backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        backBtn.setTitleColor(.blue, for: UIControlState.normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        
        var rightBtn: UIButton!
        rightBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 25))
        rightBtn.setImage(UIImage(named: "add.png"), for: UIControlState.normal)
        rightBtn.addTarget(self, action: #selector(addNoteBook), for: .touchUpInside)
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        rightBtn.tintColor = .blue
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        
        tableView.separatorColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        getData()
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            NotificationCenter.default.post(name: Notification.Name("com.amad.inclass05"), object: self, userInfo: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func addNoteBook(_ sender: Any) {
        //building an alert
        let alertController = UIAlertController(title: "New NoteBook", message: "Enter NoteBook Name", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            
            //getting new values
            let name = alertController.textFields?[0].text
            
            //calling the update method to update artist
            
            if name != "" {
                self.addData(title: name!)
            } else {
                self.showMsg(title: "", subTitle: "Notebook name cannot be empty.")
            }
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding two textfields to alert
        alertController.addTextField { (textField) in
            textField.placeholder = "Notebook name"
        }
        
        
        //adding action
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //presenting dialog
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func getData() {
        //observing the data changes
        refNoteBook.observe(DataEventType.value, with: { (snapshot) in
            
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                
                //clearing the list
                self.tableArr.removeAll()
                
                //iterating through all the values
                for notebook in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let notebookObj = notebook.value as? [String: AnyObject]
                    let name  = notebookObj?["name"]
                    let id  = notebookObj?["id"]
                    let created_date = notebookObj?["created_date"]
                    
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
        let key = refNoteBook.childByAutoId().key
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        
        
        //creating notebook with the given values
        let notebook = ["id":key,
                      "name": title as String,
                      "created_date": dateFormatter.string(from: Date())
        ]
        
        //adding the notebook inside the generated unique key
        refNoteBook.child(key!).setValue(notebook)
        showMsg(title: "", subTitle: "Notebook created!")
    }
    
    // MARK: - TableView Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableArr.count
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellItem") //1.
        cell?.textLabel?.text = tableArr[indexPath.row].name
        cell?.detailTextLabel?.text = "Created On " + tableArr[indexPath.row].created_date!
        print(tableArr[indexPath.row].created_date)
        return cell!
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "showNotes", sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableArr.count == 0 {
            
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
            label.text = "No Notebook created."
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNotes" {
            
            var loc = sender as! IndexPath
            let vc = segue.destination as! NotesViewController
                print(tableArr[loc.row].id)
                vc.notebookid = tableArr[loc.row].id
            
            
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
