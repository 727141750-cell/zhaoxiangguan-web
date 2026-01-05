//
//  PointsManager.swift
//  ZhaoXiangGuan
//
//  积分管理
//

import Foundation
import Combine

class PointsManager: ObservableObject {
    @Published var currentPoints: Int = 0

    private let pointsKey = "user_points"
    private let rechargeHistoryKey = "recharge_history"

    // 充值档位
    enum RechargeTier: CaseIterable {
        case basic
        case advanced
        case premium

        var title: String {
            switch self {
            case .basic: return "基础体验档"
            case .advanced: return "进阶畅玩档"
            case .premium: return "尊享特惠档"
            }
        }

        var price: Int {
            switch self {
            case .basic: return 30
            case .advanced: return 100
            case .premium: return 500
            }
        }

        var points: Int {
            switch self {
            case .basic: return 300
            case .advanced: return 1100
            case .premium: return 6000
            }
        }

        var perPhotoCost: Double {
            Double(price) / Double(points / 100)
        }

        var bonus: String {
            switch self {
            case .basic: return "基础性价比"
            case .advanced: return "多送100积分，省9元"
            case .premium: return "多送1000积分，省102元"
            }
        }
    }

    init() {
        loadPoints()
    }

    // 添加积分
    func addPoints(_ points: Int) {
        currentPoints += points
        savePoints()
    }

    // 扣除积分
    func deductPoints(_ points: Int) -> Bool {
        if currentPoints >= points {
            currentPoints -= points
            savePoints()
            return true
        }
        return false
    }

    // 检查积分是否足够
    func hasEnoughPoints(_ required: Int) -> Bool {
        return currentPoints >= required
    }

    // 充值
    func recharge(tier: RechargeTier, completion: @escaping (Bool) -> Void) {
        // 模拟支付处理
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addPoints(tier.points)
            self.saveRechargeRecord(tier: tier)
            completion(true)
        }
    }

    // 保存充值记录
    private func saveRechargeRecord(tier: RechargeTier) {
        let record: [String: Any] = [
            "tier": tier.title,
            "price": tier.price,
            "points": tier.points,
            "date": Date().timeIntervalSince1970
        ]

        var history = getRechargeHistory()
        history.append(record)
        UserDefaults.standard.set(history, forKey: rechargeHistoryKey)
    }

    // 获取充值记录
    func getRechargeHistory() -> [[String: Any]] {
        guard let history = UserDefaults.standard.array(forKey: rechargeHistoryKey) as? [[String: Any]] else {
            return []
        }
        return history
    }

    // 保存积分
    private func savePoints() {
        UserDefaults.standard.set(currentPoints, forKey: pointsKey)
    }

    // 加载积分
    private func loadPoints() {
        currentPoints = UserDefaults.standard.integer(forKey: pointsKey)

        // 检查是否已领取初始积分
        let hasReceivedInitialPoints = UserDefaults.standard.bool(forKey: "hasReceivedInitialPoints")
        if !hasReceivedInitialPoints && currentPoints == 0 {
            currentPoints = 100
            savePoints()
            UserDefaults.standard.set(true, forKey: "hasReceivedInitialPoints")
        }
    }
}
