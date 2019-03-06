//
//  MainViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2019/3/6.
//  Copyright © 2019 QDSG. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    private let segueToOperator = "SegueToOperator"

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func unwindToMainViewController(_ unwindSegue: UIStoryboardSegue) {}
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let identifier = segue.identifier else { return }
//        
//        switch identifier {
//        case segueToOperator:
//            <#code#>
//        default:
//            <#code#>
//        }
//    }
}

extension MainViewController {
    enum Section: Int {
        case observable
        
        var dataSource: [String] {
            switch self {
            case .observable:
                return ["Operator"]
            }
        }
        
        var numbersOfRow: Int {
            return dataSource.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("Unexpected section")
        }
        
        switch section {
        case .observable:
            return section.numbersOfRow
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MainViewCell.reuseIdentifier,
            for: indexPath) as? MainViewCell else {
            fatalError("Unexpected Table View Cell")
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unexpected Section")
        }
        
        switch section {
        case .observable:
            cell.label.text = section.dataSource[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else {
            fatalError("Unexpected Section")
        }
        
        switch section {
        case .observable:
            return "Observable"
        }
    }
}

extension MainViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unexpected Section")
        }
        
        switch section {
        case .observable:
            performSegue(withIdentifier: segueToOperator, sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

