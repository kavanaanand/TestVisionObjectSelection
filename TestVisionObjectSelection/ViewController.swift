//
//  ViewController.swift
//  TestVisionObjectSelection
//
//  Created by Kavana Anand on 2/5/24.
//

import UIKit

class ViewController: UIViewController {
    private let imageView = UIImageView()
    private let images = ["cheers"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .orange
        
        let img = UIImage(named: images[0])
        let cgimg = img?.cgImage
        
        print ("w - ", cgimg!.width)
        print ("h - ", cgimg!.height)
        print ("bpr - ", cgimg!.bytesPerRow)
        print ("bpp - ", cgimg!.bitsPerPixel)
        print ("bpc - ", cgimg!.bitsPerComponent)
        print ("cs - ", cgimg!.colorSpace ?? "")
        print ("bmi - ", cgimg!.bitmapInfo)
        
        let dataPtr = CFDataGetBytePtr(cgimg?.dataProvider?.data)
        
        var vr = VisionObjectRecognizerCpp(dataPtr, cgimg!.width, cgimg!.height, cgimg!.bytesPerRow)
        vr.recognizeObjects()
        
        imageView.image = img
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
        ])
    }

}

