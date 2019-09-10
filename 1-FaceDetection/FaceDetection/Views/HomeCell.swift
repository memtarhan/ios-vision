//
//  HomeCell.swift
//  FaceDetection
//
//  Created by Mehmet Tarhan on 10.09.2019.
//  Copyright © 2019 Mehmet Tarhan. All rights reserved.
//

import UIKit

class HomeCell: UICollectionViewCell {
    
    var detectedFaces: [UIView]?
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var image: UIImage? {
        didSet {
            guard let image = self.image else { return }
            cleanDetectedFaces()
            photoImageView.image = image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        self.addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.topAnchor.constraint(equalTo: topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTap() {
        cleanDetectedFaces()
        // TODO: Add face detection
    }
    
    private func cleanDetectedFaces() {
        detectedFaces?.forEach({
            $0.removeFromSuperview()
        })
        detectedFaces?.removeAll()
    }
}
