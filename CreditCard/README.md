# CreditCard 

### Detecting a Credit Card with Apple's Vision Framework

> This repo implements a iOS app that helps users to take a clean photo of their credit, debit card. 

[For more, please contact me at]: contact@memtarhan.com

###### For more please contact me at: contact@memtarhan.com 



##### Detecting a card goes as following:

```swift
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
```

```swift
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
        let image = UIImage(cgImage: cgImage!) // Detected image 
    }
```

