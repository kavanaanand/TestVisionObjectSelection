//
//  VisionObjectRecognizerCpp.cpp
//  VisionObjectRecognizer
//
//  Created by Kavana Anand on 2/2/24.
//

#include "VisionObjectRecognizerCpp.hpp"

#include <iostream>
#include <vector>

#include <VisionObjectRecognizer-Swift.h>


class VisionObjectRecognizerCppImpl {
    
public:
    VisionObjectRecognizerCppImpl(const uint8_t* buffer, size_t width, size_t height, size_t bytesPerRow) : _swiftRecognizer(VisionObjectRecognizer::VisionObjectRecognizerInternal::init(VisionRequestImage(std::move(buffer), width, height, bytesPerRow))) {
    }
    
    void finished(size_t count) {
        std::cout << "count - " << count << std::endl;
        _on_finish(count);
    }
    
    void failed(std::string error) {
        std::cout << "error - " << error << std::endl;
        _on_fail(error);
    }
    
    void set_on_finish_callback(std::function<void(size_t)> callback) {
        _on_finish = callback;
    }
    
    void set_on_fail_callback(std::function<void(std::string)> callback) {
        _on_fail = callback;
    }
    
    VisionObjectRecognizer::VisionObjectRecognizerInternal _swiftRecognizer;
    
private:
    std::function<void(size_t)> _on_finish;
    std::function<void(std::string)> _on_fail;
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
    pimpl->finished(count);
}

void VisionObjectRecognizerCpp::failed(std::string error) const {
    pimpl->failed(error);
}

void VisionObjectRecognizerCpp::set_on_finish_callback(std::function<void(size_t)> callback) {
    pimpl->set_on_finish_callback(callback);
}

void VisionObjectRecognizerCpp::set_on_fail_callback(std::function<void(std::string)> callback) {
    pimpl->set_on_fail_callback(callback);
}
