//
//  VisionObjectRecognizerCpp.hpp
//  VisionObjectRecognizer
//
//  Created by Kavana Anand on 2/2/24.
//

#ifndef VisionObjectRecognizerCpp_hpp
#define VisionObjectRecognizerCpp_hpp

#include <stdio.h>
#include <memory>
#include <vector>
#include <functional>

class VisionRequestImage {

public:
    VisionRequestImage(const uint8_t* buffer,
                       size_t width,
                       size_t height,
                       size_t bytes_per_row)
    : _width(width), _height(height), _buffer(std::move(buffer)), _bytes_per_row(bytes_per_row) {}
    
    const uint8_t* _buffer;
    size_t _bytes_per_row{0};
    size_t _width{0};
    size_t _height{0};
};

class VisionRequestCallbacks {

public:
    VisionRequestCallbacks(std::function<void(size_t)> on_finish,
                           std::function<void(std::string)> on_fail)
    : _on_finish(on_finish), _on_fail(on_fail) {}
    
    std::function<void(size_t)> _on_finish;
    std::function<void(std::string)> _on_fail;
};

class VisionObjectRecognizerCppImpl;

class VisionObjectRecognizerCpp {
    
public:
    VisionObjectRecognizerCpp(const uint8_t* buffer, size_t width, size_t height, size_t bytesPerRow);
    ~VisionObjectRecognizerCpp();
    
    void recognizeObjects();
    
private:
    VisionObjectRecognizerCppImpl *pimpl;
    
};


#endif /* VisionObjectRecognizerCpp_hpp */
