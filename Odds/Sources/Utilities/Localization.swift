import Foundation

/// A1: Full localization system for EN/中/日
/// Usage: L10n.s(.quit, settings.language)
enum L10n {
    static func s(_ key: LK, _ lang: AppLanguage) -> String {
        switch lang {
        case .en: return key.en
        case .zh: return key.zh
        case .ja: return key.ja
        }
    }
}

enum LK {
    // StatusBar
    case sys, live, settings, mkts

    // TabBar
    case all, trending, politics, crypto, watch

    // ColumnHeader
    case idx, market, prob, delta, trend

    // SectionDivider
    case category, watchlist

    // Settings
    case backToFeed, display, priceFormat, sparklines, refreshRate
    case language, locale, data, source, status, connected, lastSync
    case system, version, shortcuts, quit, search, close, expand
    case resetSetup, quitOdds

    // Search
    case searchLabel, noResults, searching, endOfList

    // Onboarding
    case setup, predictionTracker, addMarkets

    // ExpandedArea
    case openOnPoly, addWatchlist, removeWatchlist

    // Context menu
    case openPolymarket, copyLink, removeFromWatchlist

    var en: String {
        switch self {
        case .sys: return "SYS"
        case .live: return "LIVE"
        case .settings: return "SETTINGS"
        case .mkts: return "MKTS"
        case .all: return "ALL"
        case .trending: return "TRENDING"
        case .politics: return "POLITICS"
        case .crypto: return "CRYPTO"
        case .watch: return "WATCH"
        case .idx: return "IDX"
        case .market: return "MARKET"
        case .prob: return "PROB"
        case .delta: return "Δ"
        case .trend: return "TREND"
        case .category: return "CATEGORY"
        case .watchlist: return "WATCHLIST"
        case .backToFeed: return "BACK_TO_FEED"
        case .display: return "DISPLAY"
        case .priceFormat: return "PRICE_FORMAT"
        case .sparklines: return "SPARKLINES"
        case .refreshRate: return "REFRESH_RATE"
        case .language: return "LANGUAGE"
        case .locale: return "LOCALE"
        case .data: return "DATA"
        case .source: return "SOURCE"
        case .status: return "STATUS"
        case .connected: return "CONNECTED"
        case .lastSync: return "LAST_SYNC"
        case .system: return "SYSTEM"
        case .version: return "VERSION"
        case .shortcuts: return "SHORTCUTS"
        case .quit: return "QUIT"
        case .search: return "SEARCH"
        case .close: return "CLOSE"
        case .expand: return "EXPAND"
        case .resetSetup: return "RESET_SETUP"
        case .quitOdds: return "QUIT_ODDS"
        case .searchLabel: return "SEARCH:"
        case .noResults: return "NO_RESULTS"
        case .searching: return "SEARCHING..."
        case .endOfList: return "END_OF_LIST"
        case .setup: return "SETUP"
        case .predictionTracker: return "PREDICTION_MARKET_TRACKER"
        case .addMarkets: return "ADD_MARKETS"
        case .openOnPoly: return "OPEN_ON_POLY"
        case .addWatchlist: return "+ WATCHLIST"
        case .removeWatchlist: return "✓ WATCHLIST"
        case .openPolymarket: return "Open on Polymarket"
        case .copyLink: return "Copy Link"
        case .removeFromWatchlist: return "Remove from Watchlist"
        }
    }

    var zh: String {
        switch self {
        case .sys: return "系统"
        case .live: return "实时"
        case .settings: return "设置"
        case .mkts: return "市场"
        case .all: return "全部"
        case .trending: return "热门"
        case .politics: return "政治"
        case .crypto: return "加密"
        case .watch: return "关注"
        case .idx: return "序号"
        case .market: return "市场"
        case .prob: return "概率"
        case .delta: return "涨跌"
        case .trend: return "走势"
        case .category: return "分类"
        case .watchlist: return "关注列表"
        case .backToFeed: return "返回列表"
        case .display: return "显示"
        case .priceFormat: return "价格格式"
        case .sparklines: return "走势图"
        case .refreshRate: return "刷新频率"
        case .language: return "语言"
        case .locale: return "语言"
        case .data: return "数据"
        case .source: return "数据源"
        case .status: return "状态"
        case .connected: return "已连接"
        case .lastSync: return "上次同步"
        case .system: return "系统"
        case .version: return "版本"
        case .shortcuts: return "快捷键"
        case .quit: return "退出"
        case .search: return "搜索"
        case .close: return "关闭"
        case .expand: return "展开"
        case .resetSetup: return "重置引导"
        case .quitOdds: return "退出 odds"
        case .searchLabel: return "搜索:"
        case .noResults: return "没有结果"
        case .searching: return "搜索中..."
        case .endOfList: return "没有更多"
        case .setup: return "初始化"
        case .predictionTracker: return "预测市场追踪器"
        case .addMarkets: return "添加市场"
        case .openOnPoly: return "在 Polymarket 打开"
        case .addWatchlist: return "+ 关注"
        case .removeWatchlist: return "✓ 已关注"
        case .openPolymarket: return "在 Polymarket 打开"
        case .copyLink: return "复制链接"
        case .removeFromWatchlist: return "取消关注"
        }
    }

    var ja: String {
        switch self {
        case .sys: return "SYS"
        case .live: return "LIVE"
        case .settings: return "設定"
        case .mkts: return "市場"
        case .all: return "全て"
        case .trending: return "人気"
        case .politics: return "政治"
        case .crypto: return "暗号"
        case .watch: return "注目"
        case .idx: return "番号"
        case .market: return "市場"
        case .prob: return "確率"
        case .delta: return "変動"
        case .trend: return "推移"
        case .category: return "カテゴリ"
        case .watchlist: return "ウォッチリスト"
        case .backToFeed: return "フィードに戻る"
        case .display: return "表示"
        case .priceFormat: return "価格形式"
        case .sparklines: return "トレンド"
        case .refreshRate: return "更新間隔"
        case .language: return "言語"
        case .locale: return "言語"
        case .data: return "データ"
        case .source: return "ソース"
        case .status: return "状態"
        case .connected: return "接続中"
        case .lastSync: return "最終同期"
        case .system: return "システム"
        case .version: return "バージョン"
        case .shortcuts: return "ショートカット"
        case .quit: return "終了"
        case .search: return "検索"
        case .close: return "閉じる"
        case .expand: return "展開"
        case .resetSetup: return "設定リセット"
        case .quitOdds: return "odds を終了"
        case .searchLabel: return "検索:"
        case .noResults: return "結果なし"
        case .searching: return "検索中..."
        case .endOfList: return "リスト終了"
        case .setup: return "セットアップ"
        case .predictionTracker: return "予測市場トラッカー"
        case .addMarkets: return "市場を追加"
        case .openOnPoly: return "Polymarket で開く"
        case .addWatchlist: return "+ ウォッチ"
        case .removeWatchlist: return "✓ ウォッチ中"
        case .openPolymarket: return "Polymarket で開く"
        case .copyLink: return "リンクをコピー"
        case .removeFromWatchlist: return "ウォッチ解除"
        }
    }
}
