#if canImport(AppKit)
import SwiftUI

struct IssuesSidebar: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            Text(L10n.detectedIssuesTitle)
                .font(.system(size: 18, weight: .semibold))
                .tracking(6)
                .foregroundStyle(Color.black.opacity(0.55))

            if viewModel.issues.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.noResultsTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.9))
                    Text(L10n.noResultsDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.black.opacity(0.5))
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )

                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 18) {
                        ForEach(viewModel.issues) { issue in
                            IssueCard(
                                issue: issue,
                                isSelected: issue.id == viewModel.selectedIssueID
                            ) {
                                viewModel.selectIssue(issue)
                            }
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 42)
        .padding(.bottom, 28)
        .background(Color.white.opacity(0.2))
    }
}

private struct IssueCard: View {
    let issue: Issue
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(issue.title)
                            .font(.system(size: 21, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.92))
                            .multilineTextAlignment(.leading)

                        Text(issue.description)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.black.opacity(0.5))
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 10)
                }

                HStack {
                    SeverityPill(severity: issue.severity)
                    Spacer()
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.98) : Color.white.opacity(0.82))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(isSelected ? issue.severity.color.opacity(0.22) : Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(isSelected ? 0.08 : 0.04),
                radius: isSelected ? 18 : 10,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 0.992 : 1)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

private struct SeverityPill: View {
    let severity: IssueSeverity

    var body: some View {
        Text(severity.title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(severity.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(severity.color.opacity(0.12))
            )
    }
}
#endif
