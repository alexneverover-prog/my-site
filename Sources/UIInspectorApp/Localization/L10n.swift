#if canImport(AppKit)
import Foundation

enum L10n {
    private static var isRussian: Bool {
        Locale.preferredLanguages.contains(where: { $0.hasPrefix("ru") }) ||
        Locale.autoupdatingCurrent.identifier.hasPrefix("ru") ||
        Locale.current.identifier.hasPrefix("ru")
    }

    static var appName: String { text(ru: "UI Inspector", en: "UI Inspector") }
    static var issuesTitle: String { text(ru: "Проблемы", en: "Issues") }
    static var detectedIssuesTitle: String { text(ru: "НАЙДЕННЫЕ ПРОБЛЕМЫ", en: "DETECTED ISSUES") }
    static var inputTitle: String { text(ru: "Ввод", en: "Input") }
    static var dropScreenshotTitle: String { text(ru: "Скриншот", en: "Drop Screenshot") }
    static var dropScreenshotDescription: String { text(ru: "PNG, JPEG или любой другой файл изображения. Анализатор использует OCR и базовые эвристики layout.", en: "PNG, JPEG, or any image file. The analyzer uses OCR plus lightweight layout heuristics.") }
    static var chooseFile: String { text(ru: "Выбрать файл", en: "Choose File") }
    static var checksTitle: String { text(ru: "Проверки", en: "Checks") }
    static var noResultsTitle: String { text(ru: "Пока нет результатов", en: "No results yet") }
    static var noResultsDescription: String { text(ru: "Запустите анализ, чтобы проверить отступы, типографику, контраст, иерархию и выразительность CTA.", en: "Run the analyzer to inspect spacing, typography, contrast, hierarchy, and CTA clarity.") }
    static var previewTitle: String { text(ru: "Превью появится здесь", en: "Preview will appear here") }
    static var previewDescription: String { text(ru: "Загрузите скриншот интерфейса и запустите анализ, чтобы увидеть подсвеченные проблемы.", en: "Upload a UI screenshot and run analysis to see highlighted issues.") }
    static var currentScreenTitleLabel: String { text(ru: "ТЕКУЩИЙ\nЭКРАН", en: "CURRENT\nSCREEN") }
    static var currentScreenPlaceholder: String { text(ru: "Добавьте скриншот", en: "Add a screenshot") }
    static var currentScreenDetected: String { text(ru: "Checkout flow", en: "Checkout flow") }
    static var alignmentScoreTitle: String { text(ru: "Alignment score", en: "Alignment score") }
    static var recommendationsTitle: String { text(ru: "Recommendations", en: "Recommendations") }
    static var critical: String { text(ru: "Критично", en: "Critical") }
    static var warning: String { text(ru: "Предупреждение", en: "Warning") }
    static var warningsPlural: String { text(ru: "Предупреждения", en: "Warnings") }
    static var upload: String { text(ru: "Загрузить", en: "Upload") }
    static var paste: String { text(ru: "Вставить", en: "Paste") }
    static var analyze: String { text(ru: "Анализ", en: "Analyze") }
    static var analyzing: String { text(ru: "Анализируем...", en: "Analyzing...") }

    static var statusInitial: String { text(ru: "Перетащите скриншот или загрузите его, чтобы начать.", en: "Drop a screenshot or upload one to begin.") }
    static var statusInvalidImage: String { text(ru: "Не удалось открыть этот файл как изображение.", en: "Couldn't open that file as an image.") }
    static var statusLoaded: String { text(ru: "Скриншот загружен. Запустите анализ, чтобы проверить отступы, контраст и иерархию.", en: "Screenshot loaded. Run Analyze to inspect spacing, contrast, and hierarchy.") }
    static var statusPasted: String { text(ru: "Изображение вставлено из буфера обмена. Можно запускать анализ.", en: "Image pasted from the clipboard. You can run the analysis now.") }
    static var statusNeedUpload: String { text(ru: "Сначала загрузите скриншот.", en: "Upload a screenshot before running analysis.") }
    static var statusAnalyzing: String { text(ru: "Анализируем скриншот...", en: "Analyzing screenshot...") }
    static var statusNoIssues: String { text(ru: "На этом MVP-проходе явных проблем не найдено.", en: "No obvious issues found in this MVP pass.") }
    static var statusClipboardEmpty: String { text(ru: "В буфере обмена не найдено изображения.", en: "No image was found in the clipboard.") }
    static var statusClipboardUnsupported: String { text(ru: "В буфере обмена есть данные, но они не распознаны как изображение.", en: "Clipboard data was found, but it could not be recognized as an image.") }

    static func statusFoundIssues(_ count: Int) -> String {
        if isRussian {
            return "Найдено проблем: \(count). Выберите одну, чтобы подсветить ее."
        }

        return "Found \(count) issue\(count == 1 ? "" : "s"). Select one to highlight it."
    }

    static func findingsCount(_ count: Int) -> String {
        if isRussian {
            return "\(count)\nнаходок"
        }

        return "\(count)\nfindings"
    }

    static var checkSpacing: String { text(ru: "Согласованность отступов между соседними элементами", en: "Spacing consistency across stacked elements") }
    static var checkTypography: String { text(ru: "Оценка размера шрифта и межстрочного интервала", en: "Estimated typography size and line height") }
    static var checkContrast: String { text(ru: "Контраст текста относительно локального фона", en: "Text contrast against local background") }
    static var checkHierarchy: String { text(ru: "Иерархия заголовков и акцент CTA", en: "Headline hierarchy and CTA emphasis") }
    static var checkClickability: String { text(ru: "Понятность кликабельных действий", en: "Clickable affordance for action labels") }

    static func issueKindTitle(_ kind: IssueKind) -> String {
        switch kind {
        case .spacing:
            return text(ru: "Отступы", en: "Spacing")
        case .typography:
            return text(ru: "Типографика", en: "Typography")
        case .contrast:
            return text(ru: "Контраст", en: "Contrast")
        case .hierarchy:
            return text(ru: "Иерархия", en: "Hierarchy")
        case .clickability:
            return text(ru: "Кликабельность", en: "Clickability")
        }
    }

    static func smallTextSizeTitle() -> String { text(ru: "Слишком маленький текст", en: "Small text size") }
    static func smallTextSizeDescription(_ size: Int) -> String { text(ru: "Оценочный размер шрифта около \(size) px, что может ухудшать читаемость.", en: "Estimated font size is about \(size)px, which may reduce readability.") }
    static var smallTextSizeRecommendation: String { text(ru: "Увеличьте размер текста хотя бы до 14-16 px для обычного контента.", en: "Increase text size to at least 14-16px for regular content.") }

    static var tightLineHeightTitle: String { text(ru: "Слишком плотный межстрочный интервал", en: "Tight line height") }
    static var tightLineHeightDescription: String { text(ru: "Межстрочный интервал выглядит слишком сжатым и затрудняет сканирование текста.", en: "Line height looks compressed and may make text blocks harder to scan.") }
    static var tightLineHeightRecommendation: String { text(ru: "Используйте line-height не меньше 1.3 для основного текста.", en: "Use a line-height of at least 1.3x for body text.") }

    static var weakHierarchyTitle: String { text(ru: "Слабая визуальная иерархия", en: "Weak visual hierarchy") }
    static var weakHierarchyDescription: String { text(ru: "Размеры текста слишком похожи, поэтому заголовки и вспомогательный текст могут сливаться.", en: "Text sizes appear too similar, so headings and supporting copy may blend together.") }
    static var weakHierarchyRecommendation: String { text(ru: "Усильте разницу в размерах между заголовками, подзаголовками и основным текстом.", en: "Introduce stronger scale differences between headings, subheads, and body text.") }

    static var inconsistentSpacingTitle: String { text(ru: "Неровные отступы", en: "Inconsistent spacing") }
    static var inconsistentSpacingDescription: String { text(ru: "У соседних элементов заметно отличаются вертикальные отступы.", en: "Nearby elements use noticeably different vertical spacing.") }
    static var inconsistentSpacingRecommendation: String { text(ru: "Приведите этот блок к единой шкале отступов, например с шагом 8 pt или 12 pt.", en: "Align this block to a consistent spacing scale, such as 8pt or 12pt increments.") }

    static var lowContrastTitle: String { text(ru: "Низкий контраст текста", en: "Low contrast text") }
    static func lowContrastDescription(_ ratio: Double) -> String {
        if isRussian {
            return String(format: "Оценочный коэффициент контраста %.1f:1, это ниже рекомендуемого порога WCAG.", locale: Locale(identifier: "ru_RU"), ratio)
        }

        return String(format: "Estimated contrast ratio is %.1f:1, below the recommended WCAG threshold.", ratio)
    }
    static var lowContrastRecommendation: String { text(ru: "Увеличьте контраст между текстом и фоном хотя бы до 4.5:1.", en: "Increase contrast between text and its background to at least 4.5:1.") }

    static var weakCTATitle: String { text(ru: "Слабый акцент на CTA", en: "Weak CTA emphasis") }
    static var weakCTADescription: String { text(ru: "Это действие недостаточно выделяется на фоне остального контента.", en: "This action does not stand out enough compared with surrounding content.") }
    static var weakCTARecommendation: String { text(ru: "Сделайте кнопку заметнее за счет размера, контраста или более явной визуальной affordance.", en: "Increase button size, contrast, or visual affordance so the action feels clickable.") }

    private static func text(ru: String, en: String) -> String {
        isRussian ? ru : en
    }
}
#endif
