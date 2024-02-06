//
//  VisionObjectRecognizerCpp.cpp
//  VisionObjectRecognizer
//
//  Created by Kavana Anand on 2/2/24.
//

#include "VisionObjectRecognizerCpp.hpp"

#include <iostream>
#include <vector>

#include <TestVisionObjectSelection-Swift.h>


class VisionObjectRecognizerCppImpl {
    
public:
    VisionObjectRecognizerCppImpl(const uint8_t* buffer, size_t width, size_t height, size_t bytesPerRow) : _swiftRecognizer(TestVisionObjectSelection::ObjectRecognizer::init(VisionRequestImage(std::move(buffer), width, height, bytesPerRow))) {
    }
    
    void finished(size_t count) {
        std::cout << "count - " << count << std::endl;
    }
    
    void failed(std::string error) {
        std::cout << "error - " << error << std::endl;
    }

//    void recognizeObjects() {
//        _swiftRecognizer.recognizeObjects(this);
//    }

    TestVisionObjectSelection::ObjectRecognizer _swiftRecognizer;
};

VisionObjectRecognizerCpp::VisionObjectRecognizerCpp(const uint8_t* buffer, size_t width, size_t height, size_t bytesPerRow) {
    pimpl = new VisionObjectRecognizerCppImpl(buffer, width, height, bytesPerRow);
}

VisionObjectRecognizerCpp::~VisionObjectRecognizerCpp() {
//    delete pimpl;
}

void VisionObjectRecognizerCpp::recognizeObjects() {
    pimpl->_swiftRecognizer.recognizeObjects(*this);
}

void VisionObjectRecognizerCpp::finished(size_t count) const {
    std::cout << "c++ count - " << count << std::endl;
}

void VisionObjectRecognizerCpp::failed(std::string error) const {
    std::cout << "c++ error - " << error << std::endl;
}

