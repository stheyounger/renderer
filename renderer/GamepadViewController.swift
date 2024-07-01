//
//  GamepadViewController.swift
//  renderer
//
//  Created by James Penrose on 7/1/24.
//

import UIKit
import GameController
import SwiftUI

class GamepadViewController: UIViewController {
    
    var virtualController: GCVirtualController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (virtualController == nil) {
            let config: GCVirtualController.Configuration = GCVirtualController.Configuration()
            config.elements = NSSet(array: [
                GCInputButtonA,
                GCInputButtonB,
                GCInputButtonX,
                GCInputButtonY,
                GCInputLeftThumbstick,
                GCInputRightThumbstick
            ]) as! Set<String>
            
            virtualController = GCVirtualController(configuration: config)
        }
        virtualController?.connect()
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


struct GamepadView: UIViewControllerRepresentable {
    typealias UIViewControllerType = GamepadViewController
    
    func makeUIViewController(context: Context) -> GamepadViewController {
        let vc = GamepadViewController()
        // Do some configurations here if needed.
        return vc
    }
    
    func updateUIViewController(_ uiViewController: GamepadViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
