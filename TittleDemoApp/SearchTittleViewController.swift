//
//  SearchTittleViewController.swift
//  TittleDemoApp
//
//  Created by Jackie on 3/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

import UIKit
import TittleFramework

class SearchTittleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tittleListTableView: UITableView!
    
    var tittles: [String] = ["192.168.31.142"]
    let cellReuseIdentifier = "tittleCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tittleListTableView.delegate = self
        tittleListTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
}
