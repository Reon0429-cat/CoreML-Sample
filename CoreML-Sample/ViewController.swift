//
//  ViewController.swift
//  CoreML-Sample
//
//  Created by 大西 玲音 on 2023/03/22.
//

import UIKit
import CoreML
import Vision

final class ViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    
    private let imagePC = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImagePC()
        
    }

    @IBAction private func didSelectedCameraButton(_ sender: Any) {
        present(imagePC, animated: true)
    }
    
    private func setupImagePC() {
        imagePC.delegate = self
        imagePC.allowsEditing = false
        imagePC.sourceType = .camera
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            detect(image: selectedImage)
        }
        imagePC.dismiss(animated: true)
    }
    
    private func detect(image: UIImage) {
        guard let ciImage = CIImage(image: image),
              let model = try? VNCoreMLModel(for: MobileNetV2(configuration: .init()).model) else {
            return
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            
            if let firstResult = results.first {
                let objects = firstResult.identifier.components(separatedBy: ",")
                self.navigationItem.title = {
                    if objects.count == 1 {
                        return firstResult.identifier
                    }
                    return objects.first
                }()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print("debug", error)
        }
    }
    
}

extension ViewController: UINavigationControllerDelegate {
    
}
