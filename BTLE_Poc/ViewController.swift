//
//  ViewController.swift
//  BTLE_Poc
//
//  Created by Saulo Tauil on 2016-06-02.
//  Copyright © 2016 Saulo Tauil. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    var central: CBCentralManager?
    var periph: [CBPeripheral] = [];
    
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        central = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true, CBCentralManagerOptionRestoreIdentifierKey: "ba543afa-0982-4c66-ae34-4be3e3931ec9"]);

        central = CBCentralManager(delegate: self, queue: nil);

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("did connect peripheral : \(peripheral)");
        self.performSegueWithIdentifier("disclose", sender: peripheral);
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("did disconnect peripheral : \(peripheral) error: \(error)");
        
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("did fail to connect peripheral : \(peripheral) error: \(error)");
        
        let alert = UIAlertController(title: "Peripheral error", message: "Failed to connect with error: \(error?.localizedDescription)", preferredStyle: .Alert);
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
            });
        
        self.presentViewController(alert, animated: true, completion: nil);
        
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("did DISCOVER peripheral : \(peripheral) RSSI: \(RSSI)");
        print("ads Data: \(advertisementData)");
        
        if (!periph.contains( peripheral)) {
            periph.append(peripheral);
        }
        tableView.reloadData();
        
    }

    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("State updated : \(central.state.rawValue)")
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print("will restore state : \(central.state.rawValue) dic: \(dict)");
    }

    @IBAction func scan(sender: AnyObject) {
        let options: [String: AnyObject]? = nil; //[CBCentralManagerScanOptionAllowDuplicatesKey: true];
        
        if (central!.isScanning ){
            central?.stopScan();
            btnScan.setTitle("Scan", forState: UIControlState.Normal);
            periph = [];
            tableView.reloadData();
            
        } else {
            central?.scanForPeripheralsWithServices(nil, options: options)
            btnScan.setTitle("Stop", forState: UIControlState.Normal)
            
        }
        
    }
    
    
    //MARK: tableview datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periph.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath);
        let p = periph[indexPath.row];
        
        cell.textLabel?.text = p.name;
        cell.detailTextLabel?.text = "RSSI : \(p.RSSI)";
        return cell;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let p = sender as! CBPeripheral;
        
        let vc = segue.destinationViewController as! PeripheralDetailViewController;
        
        vc.per = p;
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let p = periph[indexPath.row];
        central?.connectPeripheral(p, options: nil);
        
    }
    
}

