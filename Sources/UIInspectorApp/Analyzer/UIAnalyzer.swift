#if canImport(AppKit)
import AppKit
import CoreGraphics
import Foundation
import Vision

struct UIAnalyzer {
    func analyze(image: NSImage) -> AnalysisResult {
        guard let cgImage = image.cgImage else {
            return AnalysisResult(elements: [], issues: [])
        }

        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let recognizedText = recognizeText(in: cgImage, imageSize: imageSize)
        let structuralElements = makeStructuralElements(imageSize: imageSize)
        let elements = merge(elements: recognizedText + structuralElements)
        let issues = buildIssues(from: elements, in: cgImage)

        return AnalysisResult(elements: elements, issues: issues)
    }

    private func recognizeText(in cgImage: CGImage, imageSize: CGSize) -> [UIElement] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
        } catch {
            return []
        }

        return (request.results ?? []).compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else {
                return nil
            }

            let rect = convertToImageRect(observation.boundingBox, imageSize: imageSize)
            return UIElement(
                kind: classifyTextElement(text: candidate.string),
                frame: rect,
                text: candidate.string,
                confidence: Double(observation.confidence)
            )
        }
    }

    private func makeStructuralElements(imageSize: CGSize) -> [UIElement] {
        let width = imageSize.width
        let height = imageSize.height

        let cards = [
            CGRect(x: width * 0.07, y: height * 0.18, width: width * 0.28, height: height * 0.18),
            CGRect(x: width * 0.07, y: height * 0.42, width: width * 0.28, height: height * 0.18),
            CGRect(x: width * 0.07, y: height * 0.66, width: width * 0.28, height: height * 0.18),
            CGRect(x: width * 0.58, y: height * 0.26, width: width * 0.26, height: height * 0.14),
            CGRect(x: width * 0.58, y: height * 0.5, width: width * 0.26, height: height * 0.22)
        ]

        return cards.map { UIElement(kind: .card, frame: $0, confidence: 0.35) }
    }

    private func merge(elements: [UIElement]) -> [UIElement] {
        var merged: [UIElement] = []

        for element in elements.sorted(by: { $0.frame.minY < $1.frame.minY }) {
            if let index = merged.firstIndex(where: { intersectsLoosely($0.frame, element.frame) && $0.kind == element.kind }) {
                let existing = merged[index]
                merged[index] = UIElement(
                    kind: existing.kind,
                    frame: existing.frame.union(element.frame),
                    text: existing.text ?? element.text,
                    confidence: max(existing.confidence, element.confidence)
                )
            } else {
                merged.append(element)
            }
        }

        return merged
    }

    private func buildIssues(from elements: [UIElement], in cgImage: CGImage) -> [Issue] {
        var issues: [Issue] = []
        let textElements = elements.filter { $0.kind == .text || $0.kind == .button }

        issues.append(contentsOf: analyzeTypography(textElements))
        issues.append(contentsOf: analyzeHierarchy(textElements))
        issues.append(contentsOf: analyzeSpacing(textElements + elements.filter { $0.kind == .card }))
        issues.append(contentsOf: analyzeContrast(textElements, in: cgImage))
        issues.append(contentsOf: analyzeCTA(textElements, in: cgImage))

        return deduplicate(issues)
    }

    private func analyzeTypography(_ elements: [UIElement]) -> [Issue] {
        elements.compactMap { element in
            let estimatedFontSize = max(8, element.frame.height * 0.72)
            let lineCount = max(1, CGFloat((element.text ?? "").split(separator: "\n").count))
            let estimatedLineHeight = element.frame.height / lineCount
            let ratio = estimatedLineHeight / max(estimatedFontSize, 1)

            if estimatedFontSize < 14 {
                return Issue(
                    kind: .typography,
                    severity: .warning,
                    title: L10n.smallTextSizeTitle(),
                    description: L10n.smallTextSizeDescription(Int(estimatedFontSize)),
                    recommendation: L10n.smallTextSizeRecommendation,
                    frame: element.frame,
                    elementID: element.id
                )
            }

            if ratio < 1.3 {
                return Issue(
                    kind: .typography,
                    severity: .warning,
                    title: L10n.tightLineHeightTitle,
                    description: L10n.tightLineHeightDescription,
                    recommendation: L10n.tightLineHeightRecommendation,
                    frame: element.frame,
                    elementID: element.id
                )
            }

            return nil
        }
    }

    private func analyzeHierarchy(_ elements: [UIElement]) -> [Issue] {
        let sizes = elements.map(\.frame.height).sorted()
        guard let smallest = sizes.first, let largest = sizes.last, smallest > 0 else {
            return []
        }

        guard largest / smallest < 1.35 else {
            return []
        }

        let unionFrame = elements.reduce(CGRect.null) { partial, element in
            partial == .null ? element.frame : partial.union(element.frame)
        }

        return [
            Issue(
                kind: .hierarchy,
                severity: .warning,
                title: L10n.weakHierarchyTitle,
                description: L10n.weakHierarchyDescription,
                recommendation: L10n.weakHierarchyRecommendation,
                frame: unionFrame
            )
        ]
    }

    private func analyzeSpacing(_ elements: [UIElement]) -> [Issue] {
        let sorted = elements.sorted { $0.frame.minY < $1.frame.minY }
        guard sorted.count >= 3 else {
            return []
        }

        let gaps = zip(sorted, sorted.dropFirst()).map { max(0, $1.frame.minY - $0.frame.maxY) }
        let nonZeroGaps = gaps.filter { $0 > 0 }
        guard nonZeroGaps.count >= 2 else {
            return []
        }

        let average = nonZeroGaps.reduce(0, +) / CGFloat(nonZeroGaps.count)

        return zip(zip(sorted, sorted.dropFirst()), gaps).compactMap { pair, gap in
            guard average > 0, abs(gap - average) > max(12, average * 0.35) else {
                return nil
            }

            return Issue(
                kind: .spacing,
                severity: .warning,
                title: L10n.inconsistentSpacingTitle,
                description: L10n.inconsistentSpacingDescription,
                recommendation: L10n.inconsistentSpacingRecommendation,
                frame: pair.0.frame.union(pair.1.frame)
            )
        }
    }

    private func analyzeContrast(_ elements: [UIElement], in cgImage: CGImage) -> [Issue] {
        elements.compactMap { element in
            let textColor = averageColor(in: element.frame, cgImage: cgImage)
            let backgroundColor = averageColor(in: element.frame.insetBy(dx: -12, dy: -8), cgImage: cgImage)
            let ratio = contrastRatio(textColor, backgroundColor)

            guard ratio < 4.5 else {
                return nil
            }

            return Issue(
                kind: .contrast,
                severity: ratio < 3 ? .critical : .warning,
                title: L10n.lowContrastTitle,
                description: L10n.lowContrastDescription(ratio),
                recommendation: L10n.lowContrastRecommendation,
                frame: element.frame,
                elementID: element.id
            )
        }
    }

    private func analyzeCTA(_ elements: [UIElement], in cgImage: CGImage) -> [Issue] {
        let ctaWords = ["start", "upload", "save", "continue", "submit", "buy", "download", "analyze", "sign up"]

        return elements.compactMap { element in
            let text = (element.text ?? "").lowercased()
            guard ctaWords.contains(where: text.contains) else {
                return nil
            }

            let averageTextHeight = elements.map(\.frame.height).reduce(0, +) / CGFloat(max(1, elements.count))
            let ratio = contrastRatio(
                averageColor(in: element.frame, cgImage: cgImage),
                averageColor(in: element.frame.insetBy(dx: -14, dy: -10), cgImage: cgImage)
            )

            if element.frame.height < averageTextHeight * 1.1 || ratio < 3.2 {
                return Issue(
                    kind: .clickability,
                    severity: .warning,
                    title: L10n.weakCTATitle,
                    description: L10n.weakCTADescription,
                    recommendation: L10n.weakCTARecommendation,
                    frame: element.frame,
                    elementID: element.id
                )
            }

            return nil
        }
    }

    private func deduplicate(_ issues: [Issue]) -> [Issue] {
        var unique: [Issue] = []

        for issue in issues {
            let hasDuplicate = unique.contains {
                $0.kind == issue.kind &&
                $0.title == issue.title &&
                intersectsLoosely($0.frame, issue.frame)
            }

            if !hasDuplicate {
                unique.append(issue)
            }
        }

        return unique.sorted { lhs, rhs in
            if lhs.severity == rhs.severity {
                return lhs.frame.minY < rhs.frame.minY
            }

            return lhs.severity == .critical && rhs.severity == .warning
        }
    }

    private func convertToImageRect(_ normalizedRect: CGRect, imageSize: CGSize) -> CGRect {
        CGRect(
            x: normalizedRect.minX * imageSize.width,
            y: (1 - normalizedRect.maxY) * imageSize.height,
            width: normalizedRect.width * imageSize.width,
            height: normalizedRect.height * imageSize.height
        )
    }

    private func classifyTextElement(text: String) -> UIElementKind {
        let lowered = text.lowercased()
        let ctaWords = ["start", "upload", "save", "continue", "submit", "buy", "download", "analyze", "sign up"]
        return ctaWords.contains(where: lowered.contains) ? .button : .text
    }

    private func intersectsLoosely(_ lhs: CGRect, _ rhs: CGRect) -> Bool {
        lhs.insetBy(dx: -8, dy: -8).intersects(rhs.insetBy(dx: -8, dy: -8))
    }

    private func averageColor(in frame: CGRect, cgImage: CGImage) -> RGBAColor {
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        let bounded = frame
            .intersection(CGRect(x: 0, y: 0, width: width, height: height))
            .integral

        guard bounded.width > 0, bounded.height > 0,
              let cropped = cgImage.cropping(to: bounded),
              let context = CGContext(
                data: nil,
                width: 1,
                height: 1,
                bitsPerComponent: 8,
                bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            return RGBAColor(red: 1, green: 1, blue: 1, alpha: 1)
        }

        context.interpolationQuality = .low
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        guard let data = context.data else {
            return RGBAColor(red: 1, green: 1, blue: 1, alpha: 1)
        }

        let pointer = data.bindMemory(to: UInt8.self, capacity: 4)
        return RGBAColor(
            red: CGFloat(pointer[0]) / 255,
            green: CGFloat(pointer[1]) / 255,
            blue: CGFloat(pointer[2]) / 255,
            alpha: CGFloat(pointer[3]) / 255
        )
    }

    private func contrastRatio(_ lhs: RGBAColor, _ rhs: RGBAColor) -> Double {
        let l1 = lhs.relativeLuminance
        let l2 = rhs.relativeLuminance
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return Double((lighter + 0.05) / (darker + 0.05))
    }
}

private struct RGBAColor {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    var relativeLuminance: CGFloat {
        let channels = [red, green, blue].map { channel -> CGFloat in
            if channel <= 0.03928 {
                return channel / 12.92
            }

            return pow((channel + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]
    }
}
#endif
