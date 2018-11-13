//
//  TableViewController.swift
//  ScholarHighPrototype1
//
//  Created by 広瀬陽一 on 2018/10/15.
//  Copyright © 2018年 FRESHNESS. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ChameleonFramework
import FirebaseAuth
import RealmSwift
import Realm

class TableViewController: UITableViewController {

    @IBOutlet weak var classNameBar: UINavigationItem!
    @IBOutlet weak var classView: UITableView!
   // @IBOutlet weak var searchBar: UISearchBar!
    
    

    let searchController = UISearchController(searchResultsController: nil)
    
    
    //new02
    var filteredRooms = [Room]()
    
    // new declarations
    let db = Firestore.firestore()
    let realm = try! Realm()
    let schoolName = "ynu"
    var thisClass = Class()
    var data: [String: Any]?
    var rooms = List<Room>()
    var room: Room?
    var classRef: CollectionReference {
        return db
        .collection( ["schools", schoolName, "classes", thisClass.classID, "rooms"].joined(separator: "/"))
    }
    private var roomListener: ListenerRegistration?
    let user = Auth.auth().currentUser
    
    @IBAction func addNewRoom(_ sender: Any) {
        let controller: UIAlertController = UIAlertController(title: "新しい部屋をつくる", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        
        
        controller.addAction(UIAlertAction(title: "決定",
                                           style: UIAlertAction.Style.default,
                                           handler:{(action) in
                                            let newRoomNameField = controller.textFields![0]
                                            if let roomName = newRoomNameField.text {
                                                if roomName == "" {
                                                    return
                                                }
                                                self.classRef.addDocument(data:  ["title": roomName,"topicType": "",
                                                            "latestTime": Timestamp(date: Date())])
                                            }
        }))
        controller.addAction(UIAlertAction(title: "キャンセル",
                                           style: UIAlertAction.Style.cancel,
                                           handler: nil))
        
        controller.addTextField(configurationHandler:){
            (newRoomNameField: UITextField?) -> Void in
            newRoomNameField?.placeholder = "部屋名を入力してください"
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: "アカウントデータは残りません。本当にサインアウトしますか？", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "サインアウト", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
            AppDefs.displayName = nil
        }))
        present(ac, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        searchController.searchBar.scopeButtonTitles = ["All", "assist", "assignment", "question"]
        searchController.searchBar.delegate = self
        
        //new-01
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        
  
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        definesPresentationContext = true
        
        
        
        if thisClass.initialize (title: "計算理論", day: "Tue", period: 1, teacherName: "松本勉", classID: "ofJknO8lBmuiDVjEwNjO") {
            print("succeed")
        }
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        rooms = realm.objects(Room.self).reduce(List<Room>()) { (list, element) -> List<Room> in
            list.append(element)
            return list
        }
        print(rooms)
        roomListener = classRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
            
            try! self.realm.write() {
                self.realm.add(self.rooms, update: true)
            }
        }
        
        classNameBar.title = thisClass.title
    }
    
    
    //new04
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredRooms = rooms.filter({( room : Room) -> Bool in
            
            let doesCategoryMatch = (scope == "All") || (room.topicType == scope)
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && room.title.lowercased().contains(searchText.lowercased())
            }
        })
        
        tableView.reloadData()
    }
    
    //new05
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
    private func handleDocumentChange(_ change: DocumentChange) {
        room = Room()
        guard let room = room, room.initialize(document: change.document) else {
            return
        }
        for r in rooms {
            if r == room {
                return
            }
        }
        switch change.type {
        case .added:
            addChannelToTable(room)
            
        case .modified:
            updateChannelInTable(room)
            
        case .removed:
            removeChannelFromTable(room)
        }
    }
    
    private func addChannelToTable(_ room: Room) {
        
       
        rooms.append(room)
        rooms.sort(by: {$0 > $1})
        
        guard let index = rooms.index(of: room) else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateChannelInTable(_ room: Room) {
        guard let index = rooms.index(of: room) else {
            return
        }
        
        rooms[index] = room
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChannelFromTable(_ room: Room) {
        guard let index = rooms.index(of: room) else {
            return
        }
        
        rooms.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //new06
        if isFiltering() {
            return filteredRooms.count
        }
        
        return rooms.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "room", for: indexPath)
        
        //new07
        let room: Room
        if isFiltering() {
            room = filteredRooms[indexPath.row]
        } else {
            room = rooms[indexPath.row]
        }
        cell.textLabel!.text = room.title
        //cell.textLabel?.text = rooms[indexPath.row].title
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        cell.detailTextLabel?.text = format.string(from: rooms[indexPath.row].latestTime.dateValue())
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        room = rooms[indexPath.row]
        self.performSegue(withIdentifier: "toRoom", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRoom" {
            let roomController: RoomController  = segue.destination as! RoomController
            roomController.thisClass = thisClass
        /*    guard let room = room else {
                print("err: room")
                return
            }
*/
            print("good: room")
            print(room)
            roomController.room = room
            print(roomController.room?.title)
            roomController.user = user
        }
        
    }
  
}

extension TableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
}

extension TableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
