
//  AppManager.swift
//  GooglePlacesDemo
//
//  Created by Eric Stein on 5/29/20.
//  Copyright © 2020 Eric Stein All rights reserved.

import Foundation
import UIKit

class AppManager{
    
    static let shared = AppManager()
    
    init(){}
    
    func showAlert(title:String,msg:String,vc:UIViewController){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        vc.present(alert, animated: true, completion: nil)
    }
}
