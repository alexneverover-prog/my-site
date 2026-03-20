<<<<<<< ours
#if canImport(AppKit)
=======
#if os(macOS)
>>>>>>> theirs
import SwiftUI

struct IssuesSidebar: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
<<<<<<< ours
                Text(L10n.issuesTitle)
                    .font(.title2.weight(.semibold))
                Spacer()
                Text("\(viewModel.issues.count)")
                    .font(.system(size: 13, weight: .semibold))
=======
                Text("Найденные проблемы")
                    .font(.title3.bold())
                Spacer()
                Text("\(viewModel.issues.count)")
                    .font(.headline.monospacedDigit())
>>>>>>> theirs
                    .foregroundStyle(.secondary)
            }

            if viewModel.issues.isEmpty {
<<<<<<< ours
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.noResultsTitle)
                        .font(.headline)
                    Text(L10n.noResultsDescription)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.secondary.opacity(0.08))
                )

=======
                ContentUnavailableView(
                    "Пока пусто",
                    systemImage: "checkmark.seal",
                    description: Text("После анализа здесь появятся warning и critical замечания с рекомендациями.")
                )
>>>>>>> theirs
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.issues) { issue in
<<<<<<< ours
                            IssueCard(
                                issue: issue,
                                isSelected: issue.id == viewModel.selectedIssueID
                            ) {
                                viewModel.selectIssue(issue)
                            }
=======
                            IssueRow(issue: issue, isSelected: viewModel.selectedIssueID == issue.id)
                                .onTapGesture {
                                    viewModel.selectIssue(issue)
                                }
>>>>>>> theirs
                        }
                    }
                }
            }
        }
<<<<<<< ours
        .padding(24)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

private struct IssueCard: View {
    let issue: Issue
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(issue.severity.title)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(issue.severity.color.opacity(0.14))
                        .clipShape(Capsule())
                        .foregroundStyle(issue.severity.color)
                    Spacer()
                    Text(L10n.issueKindTitle(issue.kind))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Text(issue.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(issue.description)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                Text(issue.recommendation)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? issue.severity.overlayColor.opacity(0.14) : Color.white.opacity(0.72))
            )
            .shadow(
                color: issue.severity.overlayColor.opacity(isSelected ? 0.14 : 0.04),
                radius: isSelected ? 16 : 8,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 0.985 : 1.0)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
=======
        .padding(20)
    }
}

private struct IssueRow: View {
    let issue: Issue
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(issue.title)
                        .font(.headline)
                    Text(issue.kind.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                SeverityBadge(severity: issue.severity)
            }

            Text(issue.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(issue.recommendation, systemImage: "wand.and.stars")
                .font(.footnote)
                .foregroundStyle(.primary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? issue.severity.color.opacity(0.12) : Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? issue.severity.color : Color.black.opacity(0.06), lineWidth: isSelected ? 2 : 1)
        )
    }
}

private struct SeverityBadge: View {
    let severity: IssueSeverity

    var body: some View {
        Text(severity.title)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(severity.color.opacity(0.16))
            .foregroundStyle(severity.color)
            .clipShape(Capsule())
    }
}

>>>>>>> theirs
#endif
