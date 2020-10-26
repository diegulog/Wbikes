//
//  BottomSheetView.swift
//  WBikes
//
//  Created by Diego on 16/10/2020.
//

import UIKit

class BottomSheetView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bikesLabel: UILabel!
    @IBOutlet weak var slotsLabel: UILabel!
    @IBOutlet weak var buttomDirections: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!

    var id: String? = nil
    var buttonDirectionsAction: (()->Void)?
    var buttonFavoriteAction: (()->Void)?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        // standard initialization logic
        let nib = UINib(nibName: "BottomSheetView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        buttomDirections.layer.cornerRadius = 5
        addSubview(contentView)
    }
    
    func updateData(station: Station){
        clearData()
        self.id = station.id
        if let address = station.address ?? station.name {
            self.addressLabel.text = address
        }
        self.bikesLabel.text = "\(station.freeBikes)"
        self.slotsLabel.text = "\(station.emptySlots)"
        setFavorite(station.isFavorite)

    }
    
    func setFavorite(_ isFavorite: Bool){
        self.favoriteButton.setImage( isFavorite ? UIImage( named: "favorite_fill") : UIImage( named: "favorite"), for: .normal)
    }
    
    func clearData(){
        self.addressLabel.text = ""
        self.bikesLabel.text = ""
        self.slotsLabel.text = ""
        setFavorite(false)

    }
    
    func animated(x: CGFloat, y: CGFloat)  {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.frame = CGRect(x: x, y: y , width: self.frame.width, height: self.frame.height)
        }, completion: nil)
    }
    
    func setRoundCorners(radius: CGFloat) {
        contentView.roundCorners(corners: [.topLeft, .topRight], radius: radius)
    }

    
    @IBAction func buttomLike(_ sender: Any) {
        buttonFavoriteAction?()

    }
    
    @IBAction func buttomDirections(_ sender: Any) {
        buttonDirectionsAction?()
    }
    @IBAction func closeAction(_ sender: Any) {
        animated(x: 0, y: UIScreen.main.bounds.size.height )
    }
    
}
