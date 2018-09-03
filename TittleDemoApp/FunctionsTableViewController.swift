//
//  FunctionsTableViewController.swift
//  TittleDemoApp
//
//  Created by Jackie on 30/8/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

import UIKit
import TittleFramework
// Using CocoaAsyncSocket for socket to demo how to use the TittleFramework
import CocoaAsyncSocket

class FunctionsTableViewController: UITableViewController, GCDAsyncSocketDelegate {
    
    @IBOutlet weak var colorRTextField: UITextField!
    @IBOutlet weak var colorGTextField: UITextField!
    @IBOutlet weak var colorBTextField: UITextField!
    @IBOutlet weak var intensityTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    // init TittleLightControl
    let tittleLightCtrl = TittleLightControl()
    let TAG_LIGHT_MODE:Int = 1
    
    var clientSocket:GCDAsyncSocket!
    var serverPort:UInt16 = 0
    var serverIP: String = "192.168.31.142"
    
    var mainQueue = DispatchQueue.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let helloLogger = HelloLogger()
        helloLogger.hello(withText: "World")
        
        serverPort = tittleLightCtrl.defaultSocketPort()
        
        //        connectToTittle(ip: serverIP, port: serverPort)
        statusLabel.text = "Connecting Tittle"
        connectToTittle(ip: serverIP, port: 19999)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Button Actions
    @IBAction func changeColorButtonDidPressed(_ sender: UIButton) {
        setLightMode(isOn: true)
    }
    
    @IBAction func changeIntensityButtonPressed(_ sender: UIButton) {
        setLightMode(isOn: true)
    }
    
    @IBAction func lightSwitchValueChanged(_ sender: UISwitch) {
        setLightMode(isOn: sender.isOn)
    }
    
    // MARK -
    func setLightMode(isOn: Bool!) {
        
        // get color RGB and intensity from text fields ot set to switch off
        let colorR: Int32! = isOn ? Int32(colorRTextField.text!) ?? 0 : 0
        let colorG: Int32! = isOn ? Int32(colorGTextField.text!) ?? 0 : 0
        let colorB: Int32! = isOn ? Int32(colorBTextField.text!) ?? 0 : 0
        let intensity: Int32! = isOn ? Int32(intensityTextField.text!) ?? 0 : 0
        
        
        // Using Tittle SDK to prepare the data package
        let lightModePackage: Data! = tittleLightCtrl.lightModePackage(withR: colorR, g: colorG, b: colorB, intensity: intensity)
        print("Package - ", lightModePackage! as NSData)
        
        // Send the package to Tittle Light via TCP socket
        sendData(data: lightModePackage, tag: TAG_LIGHT_MODE)
        
    }
    
    func sendData(data: Data, tag: Int) {
        print("sending data - ", data as NSData)
        statusLabel.text = "sending data"
        clientSocket.write(data, withTimeout: -1, tag: tag)
        clientSocket.readData(withTimeout: -1, tag: tag)
    }
    
    // MARK: Socket
    
    func connectToTittle(ip: String, port: UInt16) {
        do {
            
            clientSocket = GCDAsyncSocket()
            
            clientSocket.delegate = self
            
            clientSocket.delegateQueue = DispatchQueue.global()
            
            try clientSocket.connect(toHost: ip, onPort: port)
            
        }
        catch {
            
            print("error")
            statusLabel.text = "error connect to Tittle"
            
        }
    }
    
    func socket(_ sock:GCDAsyncSocket, didConnectToHost host:String, port:UInt16) {
        
        print("connected！")
        
        clientSocket.readData(withTimeout: -1, tag:0)
        
        DispatchQueue.main.async{
            self.statusLabel.text = "Connected to Tittle"
        }
        
        
    }
    
    func socketDidDisconnect(_ sock:GCDAsyncSocket, withError err:Error?) {
        
        print("disconnected!")
        DispatchQueue.main.async{
            self.statusLabel.text = "Disconnected to Tittle"
        }
    }
    
    
    func socket(_ sock:GCDAsyncSocket, didRead data:Data, withTag tag:Int) {
        print("received data - ", data as NSData)
        
        DispatchQueue.main.async{
            self.statusLabel.text = "Received data from Tittle"
        }
    }
    
    
    
    
    
}
