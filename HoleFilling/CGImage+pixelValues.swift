//
//  CGImage+pixelValues.swift
//  HoleFilling
//
//  Created by Alexandre Freire on 15/01/2019.
//  Copyright © 2019 Alexandre Freire. All rights reserved.
//

import CoreGraphics

extension CGImage {
    func pixelValues() -> (pixelValues: [UInt8]?, width: Int, height: Int)
    {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        width = self.width
        height = self.height
        let bitsPerComponent = self.bitsPerComponent
        let bytesPerRow = self.bytesPerRow
        let totalBytes = height * bytesPerRow
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var intensities = [UInt8](repeating: 0, count: totalBytes)
        
        let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
        contextRef?.draw(self, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
        
        pixelValues = intensities
        
        
        return (pixelValues, width, height)
    }
}

func image(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage?
{
    var imageRef: CGImage?
    if var pixelValues = pixelValues {
        let bitsPerComponent = 8
        let bytesPerPixel = 1
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        imageRef = withUnsafePointer(to: &pixelValues, {
            ptr -> CGImage? in
            var imageRef: CGImage?
            let colorSpaceRef = CGColorSpaceCreateDeviceGray()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
            let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
            let releaseData: CGDataProviderReleaseDataCallback = {
                (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            }
            
            if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
                imageRef = CGImage(width: width,
                                   height: height,
                                   bitsPerComponent: bitsPerComponent,
                                   bitsPerPixel: bitsPerPixel,
                                   bytesPerRow: bytesPerRow,
                                   space: colorSpaceRef,
                                   bitmapInfo: bitmapInfo,
                                   provider: providerRef,
                                   decode: nil,
                                   shouldInterpolate: false,
                                   intent: CGColorRenderingIntent.defaultIntent)
            }
            
            return imageRef
        })
    }
    
    return imageRef
}

extension CGImage {
    func asbsd() {
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4;
        let bytesPerRow = bytesPerPixel * width;
        let bitsPerComponent = 8;
        
        
        let pixels =  calloc(height * width, MemoryLayout<UInt32>.size)
        
        
        var context = CGContext(data: pixels, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorspace, bitmapInfo: 0)
        
        context?.draw(self, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))

        for x in 0..<width {
            for y in 0..<height {
                //Here is your raw pixels
                let offset = 4*((Int(width) * Int(y)) + Int(x))
                let alpha = pixels?[offset]
                let red = pixels[offset+1]
                let green = pixels[offset+2]
                let blue = pixels[offset+3]
            }
        }
    }
}
