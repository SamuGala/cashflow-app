import SwiftUI
import WidgetKit

/// Shared with the app through the App Group; written by SceneDelegate when
/// Flutter syncs the month summary.
enum WidgetStore {
  static let suite = "group.com.samugalasso.cashflowApp"

  static func snapshot() -> MonthSnapshot {
    let defaults = UserDefaults(suiteName: suite)
    func text(_ key: String, _ fallback: String) -> String {
      defaults?.string(forKey: key) ?? fallback
    }
    return MonthSnapshot(
      month: text("month", ""),
      balanceLabel: text("balanceLabel", "Saldo del mese"),
      balance: text("balance", "—"),
      balanceNegative: defaults?.bool(forKey: "balanceNegative") ?? false,
      incomeLabel: text("incomeLabel", "Entrate"),
      income: text("income", "—"),
      expenseLabel: text("expenseLabel", "Uscite"),
      expense: text("expense", "—"),
      addExpenseLabel: text("addExpenseLabel", "Uscita"),
      addIncomeLabel: text("addIncomeLabel", "Entrata"),
      receiptLabel: text("receiptLabel", "Ricevuta"),
      monthName: text("monthName", ""),
      availableLabel: text("availableLabel", "Disponibile"),
      available: text("available", "—"),
      availableNegative: defaults?.bool(forKey: "availableNegative") ?? false,
      spentPercent: defaults?.object(forKey: "spentPercent") as? Int ?? -1,
      spentCaption: text("spentCaption", "delle entrate già spese")
    )
  }
}

struct MonthSnapshot {
  let month: String
  let balanceLabel: String
  let balance: String
  let balanceNegative: Bool
  let incomeLabel: String
  let income: String
  let expenseLabel: String
  let expense: String
  let addExpenseLabel: String
  let addIncomeLabel: String
  let receiptLabel: String
  let monthName: String
  let availableLabel: String
  let available: String
  let availableNegative: Bool
  /// Share of the month's income already spent; -1 without income.
  let spentPercent: Int
  let spentCaption: String
}

struct MonthEntry: TimelineEntry {
  let date: Date
  let snapshot: MonthSnapshot
}

struct MonthProvider: TimelineProvider {
  func placeholder(in context: Context) -> MonthEntry {
    MonthEntry(date: Date(), snapshot: WidgetStore.snapshot())
  }

  func getSnapshot(in context: Context, completion: @escaping (MonthEntry) -> Void) {
    completion(MonthEntry(date: Date(), snapshot: WidgetStore.snapshot()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<MonthEntry>) -> Void) {
    // The app reloads the timeline on every change; refresh daily anyway so
    // the month label rolls over.
    let entry = MonthEntry(date: Date(), snapshot: WidgetStore.snapshot())
    let tomorrow = Calendar.current.startOfDay(
      for: Date().addingTimeInterval(86_400)
    )
    completion(Timeline(entries: [entry], policy: .after(tomorrow)))
  }
}

private extension Color {
  static func vault(light: UInt32, dark: UInt32) -> Color {
    Color(UIColor { traits in
      let hex = traits.userInterfaceStyle == .dark ? dark : light
      return UIColor(
        red: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: 1
      )
    })
  }

  static let vaultSurface = vault(light: 0xFFFFFF, dark: 0x182431)
  static let vaultInk = vault(light: 0x0A132C, dark: 0xF5F7FC)
  static let vaultMuted = vault(light: 0x74809A, dark: 0xA2B0C9)
  static let vaultPrimary = vault(light: 0x4654EE, dark: 0x969DFF)
  static let vaultOnPrimary = vault(light: 0xFFFFFF, dark: 0x0E1722)
  static let vaultTonal = vault(light: 0xEEF0FE, dark: 0x243148)
  static let vaultIncome = vault(light: 0x17734E, dark: 0x82DFB4)
  static let vaultExpense = vault(light: 0xC93545, dark: 0xFF8E9C)
  // Home section tint, as in the app.
  static let vaultHomeTop = vault(light: 0xFFFFFF, dark: 0x1C2350)
  static let vaultHomeBottom = vault(light: 0xE9EBFD, dark: 0x10152B)
  static let vaultRingTrack = vault(light: 0xE3E6FD, dark: 0x262E5C)
}

private enum Links {
  static let addExpense = URL(string: "pocketvault:///add")!
  static let addIncome = URL(string: "pocketvault:///add?flow=income")!
  static let scan = URL(string: "pocketvault:///scan")!
}

/// Small widget: a "+" for a new expense, the month, "Disponibile" as on
/// Home and a ring with the share of income already spent. Small widgets
/// have a single tap target, so the whole widget opens a new expense.
struct SmallMonthView: View {
  let data: MonthSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 6) {
        Image(systemName: "plus")
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(.vaultOnPrimary)
          .frame(width: 24, height: 24)
          .background(Color.vaultPrimary)
          .clipShape(Circle())
          .accessibilityLabel(Text(data.addExpenseLabel))
        Text(data.monthName)
          .font(.system(size: 13, weight: .semibold))
          .foregroundColor(.vaultMuted)
          .lineLimit(1)
      }
      Spacer(minLength: 6)
      Text(data.availableLabel)
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(.vaultMuted)
      Text(data.available)
        .font(.system(size: 26, weight: .heavy))
        .foregroundColor(data.availableNegative ? .vaultExpense : .vaultInk)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
      Spacer(minLength: 6)
      HStack(spacing: 8) {
        ZStack {
          Circle()
            .stroke(Color.vaultRingTrack, lineWidth: 5)
          if data.spentPercent >= 0 {
            Circle()
              .trim(from: 0, to: min(CGFloat(data.spentPercent) / 100, 1))
              .stroke(
                data.spentPercent > 100 ? Color.vaultExpense : Color.vaultPrimary,
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
              )
              .rotationEffect(.degrees(-90))
          }
          Text(data.spentPercent >= 0 ? "\(data.spentPercent)%" : "—")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.vaultInk)
            .minimumScaleFactor(0.6)
        }
        .frame(width: 44, height: 44)
        Text(data.spentCaption)
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(.vaultMuted)
          .lineLimit(3)
          .minimumScaleFactor(0.8)
      }
    }
    .widgetURL(Links.addExpense)
  }
}

struct MonthWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: MonthEntry

  var body: some View {
    let data = entry.snapshot
    if family == .systemSmall {
      SmallMonthView(data: data)
    } else {
      mediumBody(data)
    }
  }

  private func mediumBody(_ data: MonthSnapshot) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("Pockets Vault")
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(.vaultInk)
        Spacer(minLength: 4)
        Text(data.month)
          .font(.system(size: 11))
          .foregroundColor(.vaultMuted)
          .lineLimit(1)
      }
      Spacer(minLength: 8)
      Text(data.balanceLabel)
        .font(.system(size: 11))
        .foregroundColor(.vaultMuted)
      Text(data.balance)
        .font(.system(size: family == .systemSmall ? 22 : 26, weight: .bold))
        .foregroundColor(data.balanceNegative ? .vaultExpense : .vaultInk)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
      if family == .systemSmall {
        Spacer(minLength: 8)
        Link(destination: Links.addExpense) {
          Text("+ \(data.addExpenseLabel)")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.vaultOnPrimary)
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(Color.vaultPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
      } else {
        HStack(spacing: 16) {
          amount(data.incomeLabel, data.income, .vaultIncome)
          amount(data.expenseLabel, data.expense, .vaultExpense)
          Spacer(minLength: 0)
        }
        .padding(.top, 6)
        Spacer(minLength: 10)
        HStack(spacing: 8) {
          action("+ \(data.addExpenseLabel)", Links.addExpense, primary: true)
          action("+ \(data.addIncomeLabel)", Links.addIncome, primary: false)
          action(data.receiptLabel, Links.scan, primary: false)
        }
      }
    }
    // Medium and large widgets route each Link on its own.
  }

  private func amount(_ label: String, _ value: String, _ color: Color) -> some View {
    VStack(alignment: .leading, spacing: 1) {
      Text(label)
        .font(.system(size: 11))
        .foregroundColor(.vaultMuted)
      Text(value)
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(color)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
  }

  private func action(_ title: String, _ url: URL, primary: Bool) -> some View {
    Link(destination: url) {
      Text(title)
        .font(.system(size: 13, weight: .bold))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .foregroundColor(primary ? .vaultOnPrimary : .vaultPrimary)
        .frame(maxWidth: .infinity, minHeight: 36)
        .background(primary ? Color.vaultPrimary : Color.vaultTonal)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
  }
}

/// Card surface with the Home tint fading in from the bottom.
struct WidgetBackground: View {
  var body: some View {
    LinearGradient(
      colors: [.vaultHomeTop, .vaultHomeBottom],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}

struct PocketsVaultMonthWidget: Widget {
  let kind = "PocketsVaultMonthWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MonthProvider()) { entry in
      if #available(iOS 17.0, *) {
        MonthWidgetView(entry: entry)
          .containerBackground(for: .widget) { WidgetBackground() }
      } else {
        MonthWidgetView(entry: entry)
          .padding(16)
          .background(WidgetBackground())
      }
    }
    .configurationDisplayName("Pockets Vault")
    .description(Text("widget.description"))
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct PocketsVaultWidgetBundle: WidgetBundle {
  var body: some Widget {
    PocketsVaultMonthWidget()
  }
}
