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
    
    var baseArray = [String]()
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
    var tacoToSave = [String: String]()
    var tacoName = ""
    
    @IBOutlet weak var chooseBaseBtn: UIButton!
    @IBAction func chooseBaseBtn(_ sender: Any) {
        baseArray = downloadData(layer: "base")
        showPickerViewAnimation(btn: chooseBaseBtn, shouldGrow: true)
    }
    @IBOutlet weak var chooseCondimentBtn: UIButton!
    @IBAction func chooseCondimentBtn(_ sender: Any) {
        condimentsArray = downloadData(layer: "condiment")
        showPickerViewAnimation(btn: chooseCondimentBtn, shouldGrow: true)
    }
    @IBOutlet weak var chooseMixInBtn: UIButton!
    @IBAction func chooseMixInBtn(_ sender: Any) {
        mixInArray = downloadData(layer: "mix-in")
        showPickerViewAnimation(btn: chooseMixInBtn, shouldGrow: true)
    }
    @IBOutlet weak var chooseSeasoningBtn: UIButton!
    @IBAction func chooseSeasoningBtn(_ sender: Any) {
        seasoningArray = downloadData(layer: "seasoning")
        showPickerViewAnimation(btn: chooseSeasoningBtn, shouldGrow: true)
    }
    @IBOutlet weak var chooseShellBtn: UIButton!
    @IBAction func chooseShellBtn(_ sender: Any) {
        shellArray = downloadData(layer: "shell")
        showPickerViewAnimation(btn: chooseShellBtn, shouldGrow: true)
    }
    @IBOutlet weak var doneBtn: UIButton!
    @IBAction func doneBtn(_ sender: Any) {
        showPickerViewAnimation(btn: buttonPicked, shouldGrow: false)
    }
    @IBOutlet weak var createTacoBtn: UIButton!
    @IBAction func createTacoBtn(_ sender: Any) {
        saveTaco()
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
            return baseArray.count
        case 2:
            return condimentsArray.count
        case 3:
            return mixInArray.count
        case 4:
            return seasoningArray.count
        case 5:
            return shellArray.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch buttonPicked.tag {
        case 1:
            return baseArray[row]
        case 2:
            return condimentsArray[row]
        case 3:
            return mixInArray[row]
        case 4:
            return seasoningArray[row]
        case 5:
            return shellArray[row]
        default:
            return "Nothing Saved"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.numberOfRows(inComponent: 0) > 1 {
            var chosenIngredient = String()
            var currentBtnTitle = String()
            switch self.buttonPicked.tag {
            case 1:
                chosenIngredient = baseArray[row]
                currentBtnTitle = "Base"
            case 2:
                chosenIngredient = condimentsArray[row]
                currentBtnTitle = "Condiment"
            case 3:
                chosenIngredient = mixInArray[row]
                currentBtnTitle = "Mix-In"
            case 4:
                chosenIngredient = seasoningArray[row]
                currentBtnTitle = "Seasoning"
            case 5:
                chosenIngredient = shellArray[row]
                currentBtnTitle = "Shell"
            default:
                break
            }
            
            if chosenIngredient.contains("Choose a") {
                buttonPicked.setTitle(currentBtnTitle, for: .normal)
            } else {
                buttonPicked.setTitle(chosenIngredient, for: .normal)
            }
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
    
    func downloadData(layer: String) -> [String] {
        var arrayPassedIn = [String]()
        DispatchQueue.global().async {
            DataService.ds.REF_CURRENT_USER.child(layer).observe( .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    arrayPassedIn.append("Nothing saved yet")
                    switch self.buttonPicked.tag {
                    case 1:
                        self.baseArray = arrayPassedIn
                    case 2:
                        self.condimentsArray = arrayPassedIn
                    case 3:
                        self.mixInArray = arrayPassedIn
                    case 4:
                        self.seasoningArray = arrayPassedIn
                    case 5:
                        self.shellArray = arrayPassedIn
                    default:
                        break
                    }
                    if arrayPassedIn.count > 0 {
                        self.pickerView.selectRow(0, inComponent: 0, animated: false)
                        self.pickerView.reloadAllComponents()
                    }
                } else{
                    arrayPassedIn.append("Choose a \(layer)...")
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            let ing = snap.key
                            arrayPassedIn.append(ing)
                            switch self.buttonPicked.tag {
                            case 1:
                                self.baseArray = arrayPassedIn
                            case 2:
                                self.condimentsArray = arrayPassedIn
                            case 3:
                                self.mixInArray = arrayPassedIn
                            case 4:
                                self.seasoningArray = arrayPassedIn
                            case 5:
                                self.shellArray = arrayPassedIn
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
    
    func createTacoName(ing: String, btn: UIButton) {
        if let ingredient = btn.title(for: .normal) {
            if ingredient != ing {
                tacoName.append(ingredient + " , ")
                tacoToSave[ing] = btn.title(for: .normal)
                btn.setTitle(ing, for: .normal)
            }
        }
    }
    
    func saveTaco() {
        createTacoName(ing: "Base", btn: chooseBaseBtn)
        createTacoName(ing: "Condiment", btn: chooseCondimentBtn)
        createTacoName(ing: "Mix-In", btn: chooseMixInBtn)
        createTacoName(ing: "Seasoning", btn: chooseSeasoningBtn)
        createTacoName(ing: "Shell", btn: chooseShellBtn)
        if tacoName != "" {
            print(" TACO TO SAVE \(tacoName)")
            DataService.ds.REF_CURRENT_USER.child("created-tacos").child(tacoName).updateChildValues(tacoToSave)
            print("Saving taco")
        }
        tacoName = ""
        print("CLEARED TACO NAME \(tacoName)")
        self.pickerView.selectRow(0, inComponent: 0, animated: false)
        self.pickerView.reloadAllComponents()
    }
}
