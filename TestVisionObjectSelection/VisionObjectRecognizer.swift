//
//  VisionObjectRecognizer.swift
//  VisionObjectRecognizer
//
//  Created by Kavana Anand on 1/30/24.
//

import Vision
import UIKit

// NSNumber

public class ObjectRecognizer {
    
    public var onFinish: ((Int) -> Void)? = nil
    public var onFail: ((String) -> Void)? = nil
    
    private(set) internal var image: CGImage
    
    public init(inputImage: VisionRequestImage) {
        let byteSize = inputImage._bytes_per_row * inputImage._height
        let data = UnsafeRawPointer(inputImage._buffer)?.assumingMemoryBound(to: UInt8.self)
        let provider = CGDataProvider(dataInfo: nil, data: data!, size: byteSize, releaseData: {
            (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
        })
        
        image = CGImage(width: inputImage._width,
                        height: inputImage._height,
                        bitsPerComponent: 8,
                        bitsPerPixel: 32,
                        bytesPerRow: inputImage._bytes_per_row,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue), // .first for apollo image buffer
                        provider: provider!,
                        decode: nil,
                        shouldInterpolate: false,
                        intent: .relativeColorimetric)!
        
        print("-------")
        print ("w - ", image.width)
        print ("h - ", image.height)
        print ("bpr - ", image.bytesPerRow)
        print ("bpp - ", image.bitsPerPixel)
        print ("bpc - ", image.bitsPerComponent)
        print ("cs - ", image.colorSpace ?? "")
        print ("bmi - ", image.bitmapInfo)
        
        requestHandler = VNImageRequestHandler(cgImage: image)
    }
    
    /// Creates and executes vision request for Object recognition
    public func recognizeObjects(resultsCallback: VisionRequestCallbacks) {
        observation = nil

        if #available(iOS 17, *) {
            let request = VNGenerateForegroundInstanceMaskRequest { [self] request, error in
                let result = request.results?.first as? VNInstanceMaskObservation
                observation = result
                
                guard result != nil else {
                    let reason = "No objects found"
                    print("error - ", reason)
//                    resultsCallback._on_fail(reason)
                    onFail?(reason)
                    return
                }
                let resultCount = result!.allInstances.count
                print("found object - ", resultCount)
//                resultsCallback._on_finish(UInt(resultCount))
                onFinish?(resultCount)
            }
            
            // Execute Vision request
            DispatchQueue.global().async { [self] in
                do {
                    try requestHandler.perform([request])
                } catch {
                    let reason = "failed to run the segmentation"
                    print("error - ", reason)
//                    resultsCallback._on_fail(reason)
                    onFail?(reason)
                }
            }
        }
    }
    
    /*
    /// Returns the index of the object present if any at the given tap location
    /// The position must be normalized point on the image
    public func instance(at position: CGPoint) -> NSNumber? {
        guard observation != nil else {
            return nil
        }

        if #available(iOS 17, *) {
            if position.x < 0 || position.y < 0 || position.x > 1 || position.y > 1 {
                return nil
            } else {
                // Find the instances at specified position
                let mask = (observation! as! VNInstanceMaskObservation).instanceMask
                let coords = VNImagePointForNormalizedPoint(position, CVPixelBufferGetWidth(mask) - 1, CVPixelBufferGetHeight(mask) - 1)
                
                CVPixelBufferLockBaseAddress(mask, .readOnly)
                let pixels = CVPixelBufferGetBaseAddress(mask)!
                let bytesPerRow = CVPixelBufferGetBytesPerRow(mask)
                let instanceLabel = pixels.load(fromByteOffset: Int(coords.y) * bytesPerRow + Int(coords.x), as: UInt8.self)
                CVPixelBufferUnlockBaseAddress(mask, .readOnly)
                
                return instanceLabel == 0 ? nil :  NSNumber(value: Int(instanceLabel))
            }
        } else {
            return nil
        }
    }
    
    /// Generate mask for the given set of object indices
    public func generateMask(forInstances indices: IndexSet) -> CGImage? {
        guard observation != nil, indicesAreValid(indices) else {
            return nil
        }
        
        if #available(iOS 17, *) {
            do {
                return try generateMask(indices)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /// Generate masked image for the given set of object indices
    public func generateMaskedImage(forInstances indices: IndexSet) -> CGImage? {
        guard observation != nil, indicesAreValid(indices) else {
            return nil
        }
        if #available(iOS 17, *) {
            do {
                return try generateMaskedImage(indices)
            } catch {
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    */
    private var requestHandler: VNImageRequestHandler
    private var observation: Any?
}

/*
private extension ObjectRecognizer {
    
    // The following method assumes observation and intances are valid
    func generateMaskedImage(_ instances: IndexSet) throws -> CGImage? {
        if #available(iOS 17, *) {
            // Generate masked image
            let output = try (observation! as! VNInstanceMaskObservation).generateMaskedImage(ofInstances: instances, from: requestHandler, croppedToInstancesExtent: true)
            let maskedImage = CIImage(cvPixelBuffer: output)
            return CIContext().createCGImage(maskedImage, from: maskedImage.extent)
        } else {
            return nil
        }
    }
    
    // The following method assumes observation and intances are valid
    func generateMask(_ instances: IndexSet) throws -> CGImage? {
        if #available(iOS 17, *) {
            // Generate mask
            let output = try (observation! as! VNInstanceMaskObservation).generateScaledMaskForImage(forInstances: instances, from: requestHandler)
            
            // Output is 32-bit floating point pixel buffer, convert it to 8-bit grayscale CGImage
            let mask = convert32BitPixelBufferTo8BitGrayscaleImage(output)
            return mask
        } else {
            return nil
        }
    }
    
    func convert32BitPixelBufferTo8BitGrayscaleImage(_ pixelBuffer: CVPixelBuffer) -> CGImage? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let mask = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = CIContext().createCGImage(mask, from: mask.extent) else {
            return nil
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // Create a bitmap context for the 8-bit grayscale image
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width,
                                      space: CGColorSpaceCreateDeviceGray(),
                                      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).rawValue) else {
            return nil
        }
        // Draw the pixel buffer data into the bitmap context
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Create a CGImage from the bitmap context
        if let resultImage = context.makeImage() {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            return resultImage
        } else {
            return nil
        }
    }
    
    func indicesAreValid(_ indices: IndexSet) -> Bool {
        if #available(iOS 17, *) {
            for index in indices {
                if (observation! as! VNInstanceMaskObservation).allInstances.contains(index) == false {
                    return false
                }
            }
            return true
        } else {
            return true
        }
    }
}
*/
