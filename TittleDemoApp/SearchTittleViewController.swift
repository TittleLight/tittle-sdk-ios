//
//  SearchTittleViewController.swift
//  TittleDemoApp
//
//  Created by Jackie on 3/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

import UIKit
import TittleFramework

class SearchTittleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GCDAsyncSocketDelegate {
    
    // init TittleLightControl
    let tittleLightCtrl = TittleLightControl()
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tittleListTableView: UITableView!
    
    var tittles: [String] = ["192.168.31.142"]
    let cellReuseIdentifier = "tittleCell"
    
    var isSearching:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tittleListTableView.delegate = self
        tittleListTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    /*
     // MARK: - tableview
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tittles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TittleListCellTableViewCell = (self.tittleListTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TittleListCellTableViewCell?)!
        
        // set the text from the data model
        cell.nameLabel?.text = self.tittles[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tittleLightCtrl.stopSearchingTittles(inController: self)
        isSearching = false
        searchButton.setTitle("Start Search", for: .normal)
        self.performSegue(withIdentifier: "ToFunctionPage", sender: self)
    }
    
    /*
     // MARK: - segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToFunctionPage" {
            let destinationVC = segue.destination as! FunctionsTableViewController
            let indexPath = self.tittleListTableView.indexPathForSelectedRow
            destinationVC.serverIP = self.tittles[(indexPath?.row)!]
        }
    }
    
    /*
     // MARK: - button actions
     */
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        if isSearching {
            tittleLightCtrl.stopSearchingTittles(inController: self)
            isSearching = false
            searchButton.setTitle("Start Search", for: .normal)
        }else {
            tittleLightCtrl.startSearchingTittles(inController: self)
            isSearching = true
            searchButton.setTitle("Stop Search", for: .normal)
        }
        
    }
    
    /*
     // MARK: - Socket delegate
     */
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket:GCDAsyncSocket ) {
        newSocket.readData(withTimeout: -1, tag: 55);
    }
    
    func socket(_ sock:GCDAsyncSocket, didRead data:Data, withTag tag:Int) {
        
        //        [self updateMapping:sock data:data];
        //        [self removeSockInPool:sock];
    }
    
}
