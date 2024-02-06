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

    void setOnFinishCallback(std::function<void(size_t)> callback) {
        _on_finish = callback;
    }

    void setOnFailCallback(std::function<void(std::string)> callback) {
        _on_fail = callback;
    }

    void recognizeObjects() {
        _swiftRecognizer.recognizeObjects(VisionRequestCallbacks(_on_finish, _on_fail));
    }

private:
    std::function<void(size_t)> _on_finish;
    std::function<void(std::string)> _on_fail;

    TestVisionObjectSelection::ObjectRecognizer _swiftRecognizer;
};

VisionObjectRecognizerCpp::VisionObjectRecognizerCpp(const uint8_t* buffer, size_t width, size_t height, size_t bytesPerRow) {
    
    auto onFinish = [](size_t count) {
        std::cout << "count - " << count << std::endl;
    };
    
    auto onFail = [](std::string error) {
        std::cout << "error - " << error << std::endl;
    };
    
    pimpl = new VisionObjectRecognizerCppImpl(buffer, width, height, bytesPerRow);
    pimpl->setOnFinishCallback(onFinish);
    pimpl->setOnFailCallback(onFail);
}

VisionObjectRecognizerCpp::~VisionObjectRecognizerCpp() {
    delete pimpl;
}

void VisionObjectRecognizerCpp::recognizeObjects() {
    pimpl->recognizeObjects();
}
