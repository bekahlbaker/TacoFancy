//
//  CreateVC.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/22/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class CreateVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var baseLayerArray = [String]()
    var condimentsArray = [String]()
    var mixInArray = [String]()
    var seasoningArray = [String]()
    var shellArray = [String]()
    var chosenBaseLayer: String!
    var chosenCondiment: String!
    var chosenMixIn: String!
    var chosenSeasoning: String!
    var chosenShell: String!
    var buttonPicked: UIButton!
    var pickerPicked: UIPickerView!
    var hasSavedItems = true
    
    @IBOutlet weak var chooseBaseBtn: UIButton!
    @IBAction func chooseBaseBtn(_ sender: Any) {
        baseLayerArray = downloadData(layer: "base-layers", baseLayerArray)
        showPickerViewAnimation(btn: chooseBaseBtn, shouldGrow: true)
    }
    @IBOutlet weak var chooseCondimentBtn: UIButton!
    @IBAction func chooseCondimentBtn(_ sender: Any) {
        condimentsArray = downloadData(layer: "condiments", condimentsArray)
        showPickerViewAnimation(btn: chooseCondimentBtn, shouldGrow: true)
    }
    @IBOutlet weak var chooseMixInBtn: UIButton!
    @IBAction func chooseMixInBtn(_ sender: Any) {
    }
    @IBOutlet weak var chooseSeasoningBtn: UIButton!
    @IBAction func chooseSeasoningBtn(_ sender: Any) {
    }
    @IBOutlet weak var chooseShellBtn: UIButton!
    @IBAction func chooseShellBtn(_ sender: Any) {
    }
    @IBOutlet weak var doneBtn: UIButton!
    @IBAction func doneBtn(_ sender: Any) {
        showPickerViewAnimation(btn: buttonPicked, shouldGrow: false)
    }
    @IBOutlet weak var createTacoBtn: UIButton!
    @IBAction func createTacoBtn(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        doneBtn.alpha = 0
        
        buttonPicked = chooseBaseBtn
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch buttonPicked.tag {
        case 1:
            return baseLayerArray.count
        case 2:
            return condimentsArray.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch buttonPicked.tag {
        case 1:
            return baseLayerArray[row]
        case 2:
            return condimentsArray[row]
        default:
            return "Nothing Saved"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch buttonPicked.tag {
        case 1:
            if hasSavedItems {
                chosenBaseLayer = baseLayerArray[row]
                buttonPicked.setTitle(chosenBaseLayer, for: .normal)
            } else {
                chosenBaseLayer = ""
            }
        case 2:
            if hasSavedItems {
                chosenCondiment = condimentsArray[row]
                buttonPicked.setTitle(chosenCondiment, for: .normal)
            } else {
                chosenCondiment = ""
            }
        default:
            break
        }
    }
    
    func showPickerViewAnimation(btn: UIButton, shouldGrow: Bool) {
        let btnBeginFrame = CGRect(x: 60, y: 50 * Double(btn.tag) , width: 200, height: 40)
        let btnEndFrame = CGRect(x: 10, y: 134.5, width: 300, height: 250)
        self.buttonPicked = btn
        
        if shouldGrow {
            btn.frame = btnBeginFrame
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
                btn.frame = btnEndFrame
            }, completion: { completion in
                UIView.animate(withDuration: 0.3, animations: {
                    btn.alpha = 0
                    self.pickerView.alpha = 1
                    self.doneBtn.alpha = 1
                })
            })
        } else {
            btn.frame = btnEndFrame
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
                btn.alpha = 1
                self.pickerView.alpha = 0
                self.doneBtn.alpha = 0
            }, completion: { completion in
                UIView.animate(withDuration: 0.3, animations: {
                    btn.frame = btnBeginFrame
                })
            })
        }
    }
    
    func downloadData(layer: String, _ arrayPassedIn: [String]) -> [String] {
        DispatchQueue.global().async {
            DataService.ds.REF_CURRENT_USER.child(layer).observe( .value, with: { (snapshot) in
                var arrayPassedIn = [String]()
                arrayPassedIn.append("Choose \(layer)...")
                if let _ = snapshot.value as? NSNull {
                    self.hasSavedItems = false
                    arrayPassedIn.append("Nothing saved yet")
                    if arrayPassedIn.count > 0 {
                        self.pickerView.selectRow(0, inComponent: 0, animated: false)
                        self.pickerView.reloadAllComponents()
                    }
                } else{
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            let ing = snap.key
                            arrayPassedIn.append(ing)
                            switch self.buttonPicked.tag {
                            case 1:
                                self.baseLayerArray = arrayPassedIn
                            case 2:
                                self.condimentsArray = arrayPassedIn
                            default:
                                break
                            }
                            if arrayPassedIn.count > 0 {
                                self.pickerView.selectRow(0, inComponent: 0, animated: false)
                                self.pickerView.reloadAllComponents()
                            }
                        }
                    }
                }
            })
        }
        return arrayPassedIn
    }
}
