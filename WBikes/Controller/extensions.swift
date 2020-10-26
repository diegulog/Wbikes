//
//  extensions.swift
//  WBikes
//
//  Created by Diego on 16/10/2020.
//

import UIKit

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIViewController {
    func alertNetworkFailure(retry: @escaping () -> Void){
        let alert = UIAlertController(title: "Error", message: "Failed to update data, please try again later", preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { _ in
            retry()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
