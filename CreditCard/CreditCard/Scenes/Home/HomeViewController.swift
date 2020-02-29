//
//  HomeViewController.swift
//  CreditCard
//
//  Created by Mehmet Tarhan on 29.02.2020.
//  Copyright © 2020 Mehmet Tarhan. All rights reserved.
//

import AVFoundation
import UIKit
import Vision

protocol HomeViewController: class {
    var presenter: HomePresenter? { get set }

    func display(image: UIImage)
}

class HomeViewControllerImpl: UIViewController {
    @IBOutlet var cameraView: UIView!
    @IBOutlet var creditCardImageView: UIImageView!
    @IBOutlet var captureView: UIView!
    @IBOutlet var redoView: UIView!

    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()

    private var frame: CVImageBuffer?

    var presenter: HomePresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        setInput()
        displayFeed()
        setOutput()

        creditCardImageView.isHidden = false
        creditCardImageView.alpha = 0.5
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_processing_queue"))
        captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
        captureSession.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer.frame = view.frame
    }

    @IBAction func didTapCapture(_ sender: UIButton) {
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            self.redoView.isHidden = false
            self.captureView.alpha = 0
        }) { _ in
            guard let frame = self.frame else { return }
            self.presenter?.detectCard(in: frame)
        }
    }

    @IBAction func didTapRedo(_ sender: UIButton) {
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            self.redoView.isHidden = true
            self.captureView.alpha = 1
            self.creditCardImageView.alpha = 0
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.creditCardImageView.image = #imageLiteral(resourceName: "credit-card")
                self.creditCardImageView.alpha = 0.5
            }
        }
    }

    private func setInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .back).devices.first else {
            fatalError("No back camera device found.")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }

    private func displayFeed() {
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = cameraView.bounds
    }

    private func setOutput() {
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]

        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_processing_queue"))
        captureSession.addOutput(videoDataOutput)

        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }

        connection.videoOrientation = .portrait
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension HomeViewControllerImpl: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.frame = frame
    }
}

// MARK: - HomeViewController

extension HomeViewControllerImpl: HomeViewController {
    func display(image: UIImage) {
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            self.redoView.isHidden = false
            self.captureView.alpha = 0
            self.creditCardImageView.image = image
            self.creditCardImageView.alpha = 1
            debugPrint("Displayed captured image")
        }) { _ in
        }
    }
}
