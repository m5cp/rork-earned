import UIKit
import PDFKit

struct JournalPDFService {
    static func generatePDF(date: Date, wins: [Win], journalNote: String?, isComeback: Bool) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 48
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in
            context.beginPage()
            var yOffset: CGFloat = margin

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let dateString = dateFormatter.string(from: date)

            let titleFont = UIFont.systemFont(ofSize: 26, weight: .bold)
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.label
            ]
            let titleRect = CGRect(x: margin, y: yOffset, width: contentWidth, height: 36)
            dateString.draw(in: titleRect, withAttributes: titleAttr)
            yOffset += 40

            let accentColor = UIColor(red: 0.15, green: 0.75, blue: 0.45, alpha: 1.0)
            let lineRect = CGRect(x: margin, y: yOffset, width: 60, height: 3)
            accentColor.setFill()
            UIBezierPath(roundedRect: lineRect, cornerRadius: 1.5).fill()
            yOffset += 20

            if wins.isEmpty && isComeback {
                let comebackFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
                let comebackAttr: [NSAttributedString.Key: Any] = [
                    .font: comebackFont,
                    .foregroundColor: UIColor(red: 0.55, green: 0.35, blue: 1.0, alpha: 1.0)
                ]
                let comebackText = "You came back. Showing up is progress."
                let comebackRect = CGRect(x: margin, y: yOffset, width: contentWidth, height: 30)
                comebackText.draw(in: comebackRect, withAttributes: comebackAttr)
                yOffset += 40
            }

            if !wins.isEmpty {
                let sectionFont = UIFont.systemFont(ofSize: 11, weight: .heavy)
                let sectionAttr: [NSAttributedString.Key: Any] = [
                    .font: sectionFont,
                    .foregroundColor: accentColor,
                    .kern: 2.0 as NSNumber
                ]
                "EARNED".draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: 18), withAttributes: sectionAttr)
                yOffset += 28

                let summaryFont = UIFont.systemFont(ofSize: 14, weight: .medium)
                let summaryAttr: [NSAttributedString.Key: Any] = [
                    .font: summaryFont,
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let summaryText = "\(wins.count) win\(wins.count == 1 ? "" : "s") earned"
                summaryText.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: 20), withAttributes: summaryAttr)
                yOffset += 32

                for win in wins {
                    if yOffset > pageHeight - margin - 60 {
                        context.beginPage()
                        yOffset = margin
                    }

                    let bulletColor = categoryUIColor(win.category)
                    bulletColor.setFill()
                    let bulletRect = CGRect(x: margin, y: yOffset + 6, width: 8, height: 8)
                    UIBezierPath(ovalIn: bulletRect).fill()

                    let winFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
                    let winAttr: [NSAttributedString.Key: Any] = [
                        .font: winFont,
                        .foregroundColor: UIColor.label
                    ]
                    let winTextRect = CGRect(x: margin + 18, y: yOffset, width: contentWidth - 18, height: 22)
                    win.text.draw(in: winTextRect, withAttributes: winAttr)
                    yOffset += 22

                    let catFont = UIFont.systemFont(ofSize: 12, weight: .medium)
                    let catAttr: [NSAttributedString.Key: Any] = [
                        .font: catFont,
                        .foregroundColor: bulletColor
                    ]
                    let catRect = CGRect(x: margin + 18, y: yOffset, width: contentWidth - 18, height: 18)
                    win.category.displayName.draw(in: catRect, withAttributes: catAttr)
                    yOffset += 30
                }
            }

            if let note = journalNote, !note.isEmpty {
                yOffset += 12

                if yOffset > pageHeight - margin - 100 {
                    context.beginPage()
                    yOffset = margin
                }

                let noteSectionFont = UIFont.systemFont(ofSize: 11, weight: .heavy)
                let noteSectionAttr: [NSAttributedString.Key: Any] = [
                    .font: noteSectionFont,
                    .foregroundColor: UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0),
                    .kern: 2.0 as NSNumber
                ]
                "JOURNAL".draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: 18), withAttributes: noteSectionAttr)
                yOffset += 28

                let noteFont = UIFont.systemFont(ofSize: 14, weight: .regular)
                let noteAttr: [NSAttributedString.Key: Any] = [
                    .font: noteFont,
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 6
                        return style
                    }()
                ]
                let noteNS = note as NSString
                let maxNoteRect = CGRect(x: margin, y: yOffset, width: contentWidth, height: pageHeight - yOffset - margin)
                let boundingRect = noteNS.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: noteAttr, context: nil)

                if yOffset + boundingRect.height > pageHeight - margin {
                    let availableHeight = pageHeight - yOffset - margin
                    noteNS.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: availableHeight), withAttributes: noteAttr)
                    context.beginPage()
                    yOffset = margin
                    let remaining = boundingRect.height - availableHeight
                    if remaining > 0 {
                        noteNS.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: remaining + 20), withAttributes: noteAttr)
                    }
                } else {
                    noteNS.draw(in: maxNoteRect, withAttributes: noteAttr)
                }
            }

            let footerFont = UIFont.systemFont(ofSize: 10, weight: .medium)
            let footerAttr: [NSAttributedString.Key: Any] = [
                .font: footerFont,
                .foregroundColor: UIColor.tertiaryLabel
            ]
            let footerText = "MVM Earned"
            let footerRect = CGRect(x: margin, y: pageHeight - margin + 10, width: contentWidth, height: 16)
            footerText.draw(in: footerRect, withAttributes: footerAttr)
        }

        return data
    }

    private static func categoryUIColor(_ category: WinCategory) -> UIColor {
        switch category {
        case .discipline: .systemOrange
        case .resilience: .systemRed
        case .selfKindness: .systemPink
        case .courage: .systemIndigo
        case .progress: .systemGreen
        case .habits: .systemTeal
        case .recovery: .systemMint
        case .relationships: .systemBlue
        case .declaration: UIColor(red: 0.55, green: 0.35, blue: 1.0, alpha: 1.0)
        }
    }
}
