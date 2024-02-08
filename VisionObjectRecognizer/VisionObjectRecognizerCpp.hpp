//
//  VisionObjectRecognizerCpp.hpp
//  VisionObjectRecognizer
//
//  Created by Kavana Anand on 2/2/24.
//

#ifndef VisionObjectRecognizerCpp_hpp
#define VisionObjectRecognizerCpp_hpp

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

class VisionObjectRecognizerCppImpl;

class VisionObjectRecognizerCpp {
    
public:
    VisionObjectRecognizerCpp(const uint8_t* buffer, size_t width, size_t height, size_t bytesPerRow);
    ~VisionObjectRecognizerCpp();
    
    void recognizeObjects();
    void set_on_finish_callback(std::function<void(size_t)> callback);
    void set_on_fail_callback(std::function<void(std::string)> callback);
    
    void finished(size_t count) const;
    void failed(std::string error) const;
    
private:
    VisionObjectRecognizerCppImpl *pimpl;
    
};


#endif /* VisionObjectRecognizerCpp_hpp */
