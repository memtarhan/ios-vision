//
//  HomePresenter.swift
//  CreditCard
//
//  Created by Mehmet Tarhan on 29.02.2020.
//  Copyright © 2020 Mehmet Tarhan. All rights reserved.
//

import UIKit
import Vision

protocol HomePresenter {
    var view: HomeViewController? { get set }

    func detectCard(in image: CVPixelBuffer)
}

class HomePresenterImpl: HomePresenter {
    var view: HomeViewController?

    /**
     Detecting a credit card from live view
     - Parameter in: A preview from live view
     */
    func detectCard(in image: CVPixelBuffer) {
        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, _: Error?) in
            DispatchQueue.main.async {
                guard let results = request.results as? [VNRectangleObservation] else { return }
                guard let rect = results.first else { return }
                self.correctPerspection(with: rect, from: image)
            }
        })

        request.minimumAspectRatio = VNAspectRatio(1.3)
        request.maximumAspectRatio = VNAspectRatio(1.6)
        request.minimumSize = Float(0.5)
        request.maximumObservations = 1

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? imageRequestHandler.perform([request])
    }

    /**
     Correcting perspection for a preview
     - Parameter with: Observation on live view
     - Parameter from: Preview
     */
    func correctPerspection(with observation: VNRectangleObservation, from buffer: CVImageBuffer) {
        var ciImage = CIImage(cvImageBuffer: buffer)

        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)

        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])

        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let image = UIImage(cgImage: cgImage!)
        /// - Saving to saved photos album
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        view?.display(image: image)
    }
}
