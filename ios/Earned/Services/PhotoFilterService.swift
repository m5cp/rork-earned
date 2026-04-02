import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

@MainActor
class PhotoFilterService {
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    func apply(filter: PhotoFilter, intensity: Float, to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let filtered = applyFilter(filter, intensity: intensity, to: ciImage)
        guard let cgImage = ciContext.createCGImage(filtered, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    private func applyFilter(_ filter: PhotoFilter, intensity: Float, to image: CIImage) -> CIImage {
        guard intensity > 0 else { return image }

        switch filter {
        case .natural:
            return image

        case .warm:
            let controls = CIFilter.temperatureAndTint()
            controls.inputImage = image
            let warmth = 6500 + intensity * 2500
            controls.neutral = CIVector(x: CGFloat(warmth), y: 0)
            controls.targetNeutral = CIVector(x: 6500, y: 0)
            guard let output = controls.outputImage else { return image }

            let vibrance = CIFilter.vibrance()
            vibrance.inputImage = output
            vibrance.amount = intensity * 0.3
            return vibrance.outputImage ?? output

        case .cool:
            let controls = CIFilter.temperatureAndTint()
            controls.inputImage = image
            let coolness = 6500 - intensity * 2000
            controls.neutral = CIVector(x: CGFloat(coolness), y: 0)
            controls.targetNeutral = CIVector(x: 6500, y: 0)
            guard let output = controls.outputImage else { return image }

            let color = CIFilter.colorControls()
            color.inputImage = output
            color.saturation = 1.0 - intensity * 0.15
            color.contrast = 1.0 + intensity * 0.05
            return color.outputImage ?? output

        case .sharp:
            let sharpen = CIFilter.sharpenLuminance()
            sharpen.inputImage = image
            sharpen.sharpness = intensity * 1.5
            guard let output = sharpen.outputImage else { return image }

            let color = CIFilter.colorControls()
            color.inputImage = output
            color.contrast = 1.0 + intensity * 0.2
            color.brightness = intensity * 0.02
            return color.outputImage ?? output

        case .fade:
            let fade = CIFilter.photoEffectFade()
            fade.inputImage = image
            guard let faded = fade.outputImage else { return image }

            return blendWithIntensity(original: image, filtered: faded, intensity: intensity)

        case .mono:
            let mono = CIFilter.photoEffectNoir()
            mono.inputImage = image
            guard let monoed = mono.outputImage else { return image }

            return blendWithIntensity(original: image, filtered: monoed, intensity: intensity)
        }
    }

    private func blendWithIntensity(original: CIImage, filtered: CIImage, intensity: Float) -> CIImage {
        let blend = CIFilter.dissolveTransition()
        blend.inputImage = original
        blend.targetImage = filtered
        blend.time = intensity
        return blend.outputImage ?? filtered
    }
}
