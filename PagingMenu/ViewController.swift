//
//  ViewController.swift
//  PagingMenu
//
//  Created by LC on 2023/9/15.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let view1 = UIView()
        view1.backgroundColor = .red
        let view2 = UIView()
        view2.backgroundColor = .yellow
        let view3 = UIView()
        view3.backgroundColor = .orange

        let selectView = UIView()
        let line = UIView()
        line.backgroundColor = .green
        line.layer.cornerRadius = 1.5
        selectView.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.bottomAnchor.constraint(equalTo: selectView.bottomAnchor),
            line.centerXAnchor.constraint(equalTo: selectView.centerXAnchor),
            line.widthAnchor.constraint(equalToConstant: 20),
            line.heightAnchor.constraint(equalToConstant: 3)
        ])

        let paging = PagingMenuController()
        paging.normalStyle = PagingBarItemStyle(color: .black.withAlphaComponent(0.6), font: UIFont.systemFont(ofSize: 14))
        paging.selectedStyle = PagingBarItemStyle(color: .black, font: UIFont.systemFont(ofSize: 17))
        paging.selectedBackgroundView = selectView
        paging.menuAlignCenter = true
        paging.items = (["Hot","Choiceness","Entertainment"],[view1,view2,view3])

        
        addChild(paging)
        paging.view.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.height-44)
        view.addSubview(paging.view)
        

        // Do any additional setup after loading the view.
    }


}

