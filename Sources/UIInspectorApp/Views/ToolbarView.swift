#if canImport(AppKit)
import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
        HStack(spacing: 18) {
            WindowControls()

            Text(L10n.appName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.6))
                .padding(.horizontal, 34)
                .padding(.vertical, 14)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color(red: 0.94, green: 0.94, blue: 0.96))
                )

            Spacer()

            StatusCapsule(text: viewModel.statusText)

            HeaderMetric(title: L10n.critical, value: viewModel.criticalCount, tint: IssueSeverity.critical.color)
            HeaderMetric(title: L10n.warningsPlural, value: viewModel.warningCount, tint: IssueSeverity.warning.color)

            Button(L10n.upload) {
                viewModel.openImporter()
            }
            .buttonStyle(SecondaryCapsuleButtonStyle())

            Button(L10n.paste) {
                viewModel.pasteFromClipboard()
            }
            .buttonStyle(SecondaryCapsuleButtonStyle())

            Button(viewModel.isAnalyzing ? L10n.analyzing : L10n.analyze) {
                viewModel.analyze()
            }
            .buttonStyle(PrimaryCapsuleButtonStyle())
            .disabled(viewModel.screenshot == nil || viewModel.isAnalyzing)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.5))
    }
}

private struct WindowControls: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(Color(red: 1.0, green: 0.37, blue: 0.34))
            Circle().fill(Color(red: 1.0, green: 0.74, blue: 0.18))
            Circle().fill(Color(red: 0.16, green: 0.78, blue: 0.25))
        }
        .frame(width: 72, height: 16)
    }
}

private struct StatusCapsule: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.black.opacity(0.5))
            .lineLimit(1)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(Color(red: 0.965, green: 0.965, blue: 0.975))
            )
            .frame(maxWidth: 280)
    }
}

private struct HeaderMetric: View {
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.38))
            Text("\(value)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }
}

private struct PrimaryCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(configuration.isPressed ? 0.78 : 0.9))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct SecondaryCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.black.opacity(0.76))
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.55 : 0.74))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
#endif
