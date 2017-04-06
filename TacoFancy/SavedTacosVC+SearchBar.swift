//
//  SavedTacosVC+SearchBar.swift
//  TacoFancy
//
//  Created by Rebekah Baker on 2/22/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit

extension SavedTacosVC {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !inSearchMode {
            inSearchMode = true
            tableView.reloadData()
        }
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            filteredSavedTacos = savedTacos.filter({ (text) -> Bool in
                let tmp: NSString = text as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
            if filteredSavedTacos.count == 0 {
                inSearchMode = false
            } else {
                inSearchMode = true
            }
            tableView.reloadData()
        case 1:
            filteredSavedIngredients = savedIngredients.filter({ (text) -> Bool in
                let tmp: NSString = text as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
            if filteredSavedIngredients.count == 0 {
                inSearchMode = false
            } else {
                inSearchMode = true
            }
            tableView.reloadData()
        case 2:
            filteredCreatedTacos = createdTacos.filter({ (text) -> Bool in
                let tmp: NSString = text as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
            if filteredCreatedTacos.count == 0 {
                inSearchMode = false
            } else {
                inSearchMode = true
            }
            tableView.reloadData()
        default:
            break
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        inSearchMode = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inSearchMode = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}
