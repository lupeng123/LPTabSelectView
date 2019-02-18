//
//  ListVC.swift
//  aaaa
//
//  Created by 路鹏 on 2018/11/9.
//  Copyright © 2018 路鹏. All rights reserved.
//

import UIKit

class ListVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.init(red: CGFloat(arc4random()%255) / 255.0, green: CGFloat(arc4random()%255) / 255.0, blue: CGFloat(arc4random()%255) / 255.0, alpha: 1)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
