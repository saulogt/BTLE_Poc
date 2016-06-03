//
//  PeripheralDetailViewController.swift
//  BTLE_Poc
//
//  Created by Saulo Tauil on 2016-06-02.
//  Copyright © 2016 Saulo Tauil. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralDetailViewController: UIViewController, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblName: UILabel!
    var per: CBPeripheral?;
    
    var services: [CBService]?;
    var characterirstics: [CBCharacteristic] = [];
    var descriptors: [CBDescriptor] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        lblName.text = "Peripheral Name: '\(per?.name ?? "NULL")' - \(per?.identifier.UUIDString)";
        per?.delegate = self;
        
            }

    @IBAction func query(sender: AnyObject) {
        
        services = [];
        characterirstics = [];
        descriptors = [];
        
        tableView.reloadData();
        
        if (per?.services != nil) {
            self.peripheral(per!, didDiscoverServices: nil);
        } else {
            per!.discoverServices(nil);
        }
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    
        descriptors = [];
        characterirstics = [];
        if (error == nil){
            self.services = peripheral.services;
            for s in peripheral.services ?? [] {
               
                //peripheral.discoverCharacteristics(nil, forService: s);
                print("s : \(s)");
            }
            tableView.reloadData();
        }
    }
    

    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        descriptors = [];
        
        if (error == nil) {
            
            characterirstics = service.characteristics ?? [];
            for c in service.characteristics ?? [] {
                
                if !characterirstics.contains( c ) {
                    //characterirstics.append( c );
                    
                    
                    //peripheral.setNotifyValue(true, forCharacteristic: c);
                }
                
                
                //peripheral.discoverDescriptorsForCharacteristic(c);
                print("c : \(c)")
            }
            tableView.reloadData();

        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error == nil) {
            
            descriptors = characteristic.descriptors ?? [];
            for d in characteristic.descriptors ?? [] {
                
                if !descriptors.contains( d ) {
                    //descriptors.append( d );
                    
                    
                }
                
                
                print("d : \(d)");
                
            }
            tableView.reloadData();
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        
        print("didWriteValueForDescriptor error : \(error)")
        
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("didWriteValueForCharacteristic error : \(error)")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return services?.count ?? 0;
        }
        else if (section == 1) {
            return characterirstics.count;
        }
        else {
            return descriptors.count;
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let l = UILabel()
        l.font = UIFont.boldSystemFontOfSize(15);
        
        if (section == 0){
            l.text = "Services";
        }
        else if (section == 1) {
            l.text = "Caracteristics (Click to send)";
        }
        else {
            l.text = "Descriptors (Click to send - crashy)";
        }
        
        return l;

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath);
        
        let section = indexPath.section;
        if (section == 0){
            let s = services![indexPath.row];
            cell.textLabel?.text = s.UUID.UUIDString;
            cell.detailTextLabel?.text = "Is Primary: \(s.isPrimary)";
        }
        else if (section == 1) {
            let c = characterirstics[indexPath.row];
            cell.textLabel?.text = c.UUID.UUIDString;
            cell.detailTextLabel?.text = "Notifying : \(c.isNotifying)";
        }
        else {
            
            let d = descriptors[indexPath.row];
            cell.textLabel?.text = d.UUID.UUIDString;
            cell.detailTextLabel?.text = "Value : \(d.value)"
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section;
        
        if (section == 0){
            let s = services![indexPath.row];
            
            per!.discoverCharacteristics(nil, forService: s);
            
            
        }
        else if (section == 1) {
            let c = characterirstics[indexPath.row];
            
            per!.setNotifyValue(true, forCharacteristic: c);
            print("Properties : \(c.properties)");
            

            let alert = UIAlertController(title: "About to send data", message: "Click ok to send", preferredStyle: .Alert);
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { (action) in
                
                let data = "Data to be sent".dataUsingEncoding(NSUTF8StringEncoding)
                
                self.per!.writeValue(data!, forCharacteristic: c, type: CBCharacteristicWriteType.WithResponse)
                
                self.per!.discoverDescriptorsForCharacteristic(c);
                
                });
            self.presentViewController(alert, animated: true, completion: nil);
            

        }
        else {
            let d = self.descriptors[indexPath.row];
            
            let alert = UIAlertController(title: "About to send", message: "click ok to send. (Crashy)", preferredStyle: .Alert);
            
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
                
                    let data = "Data to be sent".dataUsingEncoding(NSUTF8StringEncoding)
                    
                    
                    self.per?.writeValue(data!, forDescriptor: d);
                
                });
            self.presentViewController(alert, animated: true, completion: nil);
            
        }

    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("didUpdateNotificationStateForCharacteristic : \(characteristic.UUID.UUIDString) andError: \(error)");
        
    }

}
