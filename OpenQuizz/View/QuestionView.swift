//
//  QuestionView.swift
//  OpenQuizz
//
//  Created by Angelique Babin on 05/04/2019.
//  Copyright © 2019 Angelique Babin. All rights reserved.
//

import UIKit

class QuestionView: UIView {
    
    enum Style {
        case correct, incorrect, standard
    }
    
    var style: Style = .standard {
        didSet {
            setStyle(style)
        }
    }
    
    private func setStyle(_ style: Style) {
        switch style {
        case .correct:
            backgroundColor = UIColor(red: 200/255.0, green: 236/255.0, blue: 160/255.0, alpha: 1)
            icon.isHidden = false
            icon.image = UIImage(named: "Icon Correct")
        case .incorrect:
            backgroundColor = #colorLiteral(red: 0.952377975, green: 0.5273338556, blue: 0.5785703063, alpha: 1)
            icon.image = #imageLiteral(resourceName: "Icon Error")
            icon.isHidden = false
        case .standard:
            backgroundColor = #colorLiteral(red: 0.7497281432, green: 0.7690374255, blue: 0.7860509753, alpha: 1)
            icon.isHidden = true
        }
    }
    
    var title = "" {
        didSet {
            label.text = title
        }
    }
    
    @IBOutlet private var label: UILabel!
    @IBOutlet private var icon: UIImageView!
}
