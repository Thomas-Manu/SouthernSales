//
//  MarkdownViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 3/31/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import MarkdownView
import NVActivityIndicatorView

class MarkdownViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var markdownView: MarkdownView!
    var fileName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        startAnimating(type: NVActivityIndicatorType.ballScaleRippleMultiple)
        if let filepath = Bundle.main.path(forResource: fileName, ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)
                markdownView.load(markdown: contents)
            } catch {
                stopAnimating()
                navigationController?.popViewController(animated: true)
                print("[MVC] Error loading from file \(filepath)")
            }
        }
        
        markdownView.onRendered = { [weak self] height in
            self?.stopAnimating()
        }
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
