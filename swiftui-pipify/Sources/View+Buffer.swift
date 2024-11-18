//
//  Copyright 2022 • Sidetrack Tech Limited
//

import SwiftUI
import AVFoundation

@available(macOS 13.0, *)
extension View {
    /// Creates a `CMSampleBuffer` containing the rendered view.
    func makeBuffer(renderer: ImageRenderer<some View>) async throws -> CMSampleBuffer {
        // Pixel Buffer
        var buffer: CVPixelBuffer?
        let scale = await UIScreen.main.scale * 2
        await renderer.render { size, callback in
            let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
            
            let status = CVPixelBufferCreate(
                kCFAllocatorDefault,
                Int(scaledSize.width),
                Int(scaledSize.height),
                kCVPixelFormatType_32ARGB,
                [
                    kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
                    kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
                    kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary,
                ] as CFDictionary,
                &buffer
            )
            
            guard let unwrappedBuffer = buffer, status == kCVReturnSuccess else {
                logger.error("buffer not created, status: \(status)")
                return
            }
            
            CVPixelBufferLockBaseAddress(unwrappedBuffer, [])
            defer { CVPixelBufferUnlockBaseAddress(unwrappedBuffer, []) }

            let context = CGContext(
                data: CVPixelBufferGetBaseAddress(unwrappedBuffer),
                width: Int(scaledSize.width),
                height: Int(scaledSize.height),
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedBuffer),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            )
            
            guard let unwrappedContext = context else {
                logger.error("context not created")
                return
            }
            
            // Apply the scale to the context
            unwrappedContext.scaleBy(x: scale, y: scale)
            
            callback(unwrappedContext)
        }
        
        guard let unwrappedPixelBuffer = buffer else {
            logger.error("buffer not created")
            throw NSError(domain: "com.getsidetrack.pipify", code: 0)
        }
        
        // Format Description
        var formatDescription: CMFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: unwrappedPixelBuffer,
            formatDescriptionOut: &formatDescription
        )
        
        guard let unwrappedFormatDescription = formatDescription, status == kCVReturnSuccess else {
            logger.error("format description not created, status: \(status)")
            throw NSError(domain: "com.getsidetrack.pipify", code: 1)
        }
        
        // Timing Info
        let now = CMTime(
            seconds: CACurrentMediaTime(),
            preferredTimescale: 120
        )
        
        let timingInfo = CMSampleTimingInfo(
            duration: .init(seconds: 1, preferredTimescale: 60),
            presentationTimeStamp: now,
            decodeTimeStamp: now
        )

        return try CMSampleBuffer(
            imageBuffer: unwrappedPixelBuffer,
            formatDescription: unwrappedFormatDescription,
            sampleTiming: timingInfo
        )
    }
}
