//
//  ViewController.swift
//  Magic Eight Ball
//
//  Created by abdul  on 2/19/20.
//  Copyright © 2020 Makeschool. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var answers: [String] = ["yes","no", "If you're lucky", "some day"]
    
    @IBOutlet weak var userResponseLabel: UILabel!
    @IBOutlet weak var shakeItButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        shakeItButton.addTarget(self, action: #selector(shakeItButtonTapped), for: .touchUpInside)
        shakeItButton.layer.borderWidth = 1
        shakeItButton.layer.cornerRadius = 5
        shakeItButton.layer.backgroundColor = UIColor.blue.cgColor
        shakeItButton.setTitleColor(.white, for: .normal)
        
        userResponseLabel.text = ""
        userResponseLabel.font = UIFont(name: "Bangla Sangam MN", size: 30.0)
        userResponseLabel.layer.backgroundColor = UIColor.gray.cgColor
    
        
    }
    @objc func shakeItButtonTapped() {
        userResponseLabel.text = answers.randomElement()
    
    }

}

