//
//  ViewController.swift
//  StillAndVideoMediaCapture
//
//  Created by 홍창남 on 2018. 7. 21..
//  Copyright © 2018년 홍창남. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var photoButtonView: PhotoButtonView!
    @IBOutlet weak var previewView: UIView!
    let captureSession = AVCaptureSession()

    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?

    var photoOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureVideoDataOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?

    var currentImage: UIImage?
    var images: [UIImage] = []
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        photoButtonView.layer.cornerRadius = photoButtonView.frame.width / 2

        setupCaptureSession()
        setupDevice()
        setupDeviceInput()
        setupDeviceOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }

    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera],
                                                                           mediaType: .video,
                                                                           position: .unspecified)
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == .back {
                backCamera = device
            } else if device.position == .front {
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }

    func setupDeviceInput() {
        do {
            if let currentCamera = currentCamera {
                let captureDeviceInput = try AVCaptureDeviceInput.init(device: currentCamera)
                if captureSession.canAddInput(captureDeviceInput) {
                    captureSession.addInput(captureDeviceInput)
                }
            }
        } catch {
            print(error)
        }
    }

    func setupDeviceOutput() {

        videoOutput = AVCaptureVideoDataOutput()
        if let output = videoOutput {
            output.alwaysDiscardsLateVideoFrames = true

            output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
            let settings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as [String: Any]
            output.videoSettings =  settings

            captureSession.addOutput(output)
        }
    }

    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = self.previewView.frame

        self.previewView.layer.addSublayer(cameraPreviewLayer!)
    }

    func startRunningCaptureSession() {
        captureSession.startRunning()
    }

    @IBAction func photoBtnTapped(sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }

    @objc func tick() {

        if let image = currentImage {
            self.view.blink()
            self.images.append(image)
        }

        if images.count == 6 {
            timer?.invalidate()
            timer = nil
            self.performSegue(withIdentifier: "toResult", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult" {
            if let navigation = segue.destination as? UINavigationController,
                let destination = navigation.visibleViewController as? ResultViewController {
                destination.images = images
            }
        }
    }
}
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let baseAddress = UnsafeMutableRawPointer(CVPixelBufferGetBaseAddress(imageBuffer))
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            let width = CVPixelBufferGetWidth(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let newContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo:
                CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
            let cgImage = newContext?.makeImage()

            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

            if let cgImage = cgImage {
                let resultImage = UIImage(cgImage: cgImage)
                self.currentImage = resultImage
            }
        }
    }
}

extension UIView {
    func blink() {
        UIView.animate(withDuration: 0.25, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { [weak self] in
//            self?.layer.removeAllAnimations()
//        })
    }
}
