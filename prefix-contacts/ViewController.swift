//
//  ViewController.swift
//  prefix-contacts
//
//  Created by 顾晓涛 on 2018/8/27.
//  Copyright © 2018年 顾晓涛. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var updates: [String] = []
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        cell.textLabel?.text = updates[indexPath.item]
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func start(_ sender: Any) {
        let request = CNContactFetchRequest.init(keysToFetch: [
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor])
        let contactStore = CNContactStore()
        try! contactStore.enumerateContacts(with: request) { (contact, stop) in
            let lastName = contact.givenName
            let familyName = contact.familyName
            NSLog("%@-%@",familyName, lastName)
            
            let mutableContact:CNMutableContact = contact.mutableCopy() as! CNMutableContact
            mutableContact.phoneNumbers = []
            let prefix = "+86"
            for labeledValue in contact.phoneNumbers{
                let phoneValue = labeledValue.value
                let phoneNumber = phoneValue.stringValue
                let label = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: labeledValue.label!)
                NSLog("%@--%@",label,phoneNumber)
                var newPhoneNumber = ""
                if !phoneNumber.starts(with: prefix){
                    newPhoneNumber = self.reformatPhoneNumber(phoneNumber: prefix+phoneNumber)
                }else{
                    newPhoneNumber = self.reformatPhoneNumber(phoneNumber: phoneNumber)
                }
                let newPhoneValue = CNPhoneNumber(stringValue:newPhoneNumber)
                mutableContact.phoneNumbers.append(CNLabeledValue(label: labeledValue.label,value:newPhoneValue))
                self.updates.append(familyName+lastName+":"+phoneNumber+"->"+newPhoneNumber)
            }
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableContact)
            try! contactStore.execute(saveRequest)
            self.tableView.reloadData()
        }
    }
    
    private func reformatPhoneNumber(phoneNumber: String) -> String {
        var pn = phoneNumber.replacingOccurrences(of: "-", with: "")
        pn = pn.replacingOccurrences(of: " ", with: "")
        return pn
    }
}

