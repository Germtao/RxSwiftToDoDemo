//
//  MainViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2019/3/6.
//  Copyright © 2019 QDSG. All rights reserved.
//

import UIKit

enum ObservableStatus: Int {
    case operatorType
    case subjectType
}

class MainViewController: UITableViewController {
    
    private let segueToOperator = "SegueToOperator"
    private let segueToSubject = "SegueToSubject"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwindToMainViewController(_ unwindSegue: UIStoryboardSegue) {}
}

extension MainViewController {
    enum Section: Int {
        case observable
        case subject
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else {
            fatalError("Unexpected Section")
        }
        
        switch section {
        case .observable:
            return "Observable"
        case .subject:
            return "Subject"
        }
    }
}

