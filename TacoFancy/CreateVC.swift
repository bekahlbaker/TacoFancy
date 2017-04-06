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
    @IBOutlet weak var errorLbl: UILabel!
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
    var tacoName = [String]()
    var signHasBeenTurnedOn: Bool!
    var chosenIngredient: String!
    var currentBtnTitle: String!
    var hasChosenIng = false
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
        if signHasBeenTurnedOn == false && hasChosenIng == true {
            turnSign(shouldTurnOn: true)
        }
    }
    @IBOutlet weak var createTacoBtn: UIButton!
    @IBAction func createTacoBtn(_ sender: Any) {
        if hasChosenIng {
            errorLbl.text = ""
            saveTaco()
        } else {
            errorLbl.text = "You haven't chosen any ingredients to save."
        }
    }
    @IBOutlet weak var createSign: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        createOnboarding.isHidden = true
        signHasBeenTurnedOn = false
        hasChosenIng = false
        pickerView.delegate = self
        pickerView.dataSource = self
        buttonPicked = chooseBaseBtn
        checkForHasCreatedTacosOnce()
    }
    override func viewDidAppear(_ animated: Bool) {
        errorLbl.text = ""
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
            switch self.buttonPicked.tag {
            case 1:
                chosenIngredient = baseArray[row]
                if chosenIngredient != "Choose a base..." {
                    hasChosenIng = true
                  buttonPicked.setTitle(chosenIngredient, for: .normal)
                } else {
                    hasChosenIng = false
                  buttonPicked.setTitle("Choose a base...", for: .normal)
                }
            case 2:
                chosenIngredient = condimentsArray[row]
                if chosenIngredient != "Choose a condiment..." {
                    hasChosenIng = true
                    buttonPicked.setTitle(chosenIngredient, for: .normal)
                } else {
                    hasChosenIng = false
                    buttonPicked.setTitle("Choose a condiment...", for: .normal)
                }
            case 3:
                chosenIngredient = mixInArray[row]
                if chosenIngredient != "Choose a mix-in..." {
                    hasChosenIng = true
                    buttonPicked.setTitle(chosenIngredient, for: .normal)
                } else {
                    hasChosenIng = false
                    buttonPicked.setTitle("Choose a mix-in...", for: .normal)
                }
            case 4:
                chosenIngredient = seasoningArray[row]
                if chosenIngredient != "Choose a seasoning..." {
                    hasChosenIng = true
                    buttonPicked.setTitle(chosenIngredient, for: .normal)
                } else {
                    hasChosenIng = false
                    buttonPicked.setTitle("Choose a seasoning...", for: .normal)
                }
            case 5:
                chosenIngredient = shellArray[row]
                if chosenIngredient != "Choose a shell..." {
                    hasChosenIng = true
                    buttonPicked.setTitle(chosenIngredient, for: .normal)
                } else {
                    hasChosenIng = false
                    buttonPicked.setTitle("Choose a shell...", for: .normal)
                }
            default:
                break
            }
        }
    }

    func showPickerViewAnimation(btn: UIButton, shouldGrow: Bool) {
        self.buttonPicked = btn
        if shouldGrow {
            UIView.animate(withDuration: 0.5, animations: {
                self.pickerView.alpha = 1
                self.doneBtn.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.pickerView.alpha = 0
                self.doneBtn.alpha = 0
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
                } else {
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
    func saveTaco() {
        if chooseBaseBtn.title(for: .normal) != "Choose a base..." {
            tacoName.append(chooseBaseBtn.title(for: .normal)!)
            tacoToSave["base"] = chooseBaseBtn.title(for: .normal)
        }
        if chooseCondimentBtn.title(for: .normal) != "Choose a condiment..." {
            tacoName.append(chooseCondimentBtn.title(for: .normal)!)
            tacoToSave["condiment"] = chooseCondimentBtn.title(for: .normal)
        }
        if chooseSeasoningBtn.title(for: .normal) != "Choose a seasoning..." {
            tacoName.append(chooseSeasoningBtn.title(for: .normal)!)
            tacoToSave["seasoning"] = chooseSeasoningBtn.title(for: .normal)
        }
        if chooseMixInBtn.title(for: .normal) != "Choose a mix-in..." {
            tacoName.append(chooseMixInBtn.title(for: .normal)!)
            tacoToSave["mix-in"] = chooseMixInBtn.title(for: .normal)
        }
        if chooseShellBtn.title(for: .normal) != "Choose a shell..." {
            tacoName.append(chooseShellBtn.title(for: .normal)!)
            tacoToSave["shell"] = chooseShellBtn.title(for: .normal)
        }

            print(tacoName)
            let tacoNameToSave = tacoName.joined(separator: ", ")
            print(tacoNameToSave)
            DataService.ds.REF_CURRENT_USER.child("created-tacos").child(tacoNameToSave).updateChildValues(tacoToSave)
            savedTacoAlert()
    }
    func flickerSign() {
        var images: [UIImage] = []
        for i in 1...3 {
            images.append(UIImage(named: "createSign\(i)")!)
        }
        createSign.animationImages = images
        createSign.animationDuration = 0.4
        createSign.animationRepeatCount = 1
        createSign.startAnimating()
    }
    func turnSign(shouldTurnOn: Bool) {
        if shouldTurnOn {
           flickerSign()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.createSign.image = UIImage(named: "create-sign-on")
            })
            signHasBeenTurnedOn = true
        } else {
            flickerSign()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.createSign.image = UIImage(named: "create-sign-off")
            })
            signHasBeenTurnedOn = false
        }
    }
    @IBOutlet weak var createOnboarding: UIView!
    @IBOutlet weak var gotItBtn: UIButton!
    @IBAction func gotItBtnTapped(_ sender: Any) {
        createOnboarding.isHidden = true
    }
    func checkForHasCreatedTacosOnce() {
        if UserDefaults.standard.bool(forKey: "HasCreatedTacosOnce") {
            print("NOT first launch")
        } else {
            print("FIRST launch")
            UserDefaults.standard.set(true, forKey: "HasCreatedTacosOnce")
            UserDefaults.standard.synchronize()
            createOnboarding.isHidden = false
        }
    }

    func savedTacoAlert() {
        let alert = UIAlertController(title: "Success!", message: "Created taco has been successfully saved.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_: UIAlertAction) in
            self.tacoName = []
            self.tacoToSave = [:]
            self.chooseBaseBtn.setTitle("Choose a base...", for: .normal)
            self.chooseCondimentBtn.setTitle("Choose a condiment...", for: .normal)
            self.chooseMixInBtn.setTitle("Choose a mix-in...", for: .normal)
            self.chooseSeasoningBtn.setTitle("Choose a seasoning...", for: .normal)
            self.chooseShellBtn.setTitle("Choose a shell...", for: .normal)
            self.pickerView.selectRow(0, inComponent: 0, animated: false)
            self.pickerView.reloadAllComponents()
            self.turnSign(shouldTurnOn: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
