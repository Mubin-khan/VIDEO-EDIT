//
//  ContentTableViewCell.swift
//  VIDEO
//
//  Created by appsyneefo on 1/26/23.
//

import UIKit

class ContentTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    

    @IBOutlet weak var contentCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let nib = UINib(nibName: "ContentCollectionViewCell", bundle: nil)
        contentCollectionView.register(nib, forCellWithReuseIdentifier: "ContentCollectionViewCell")
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        contentCollectionView.isScrollEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as? ContentCollectionViewCell {
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: collectionView.bounds.width / 2, bottom: 0, right: collectionView.bounds.width / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 800, height: collectionView.bounds.height)
    }
    
}
