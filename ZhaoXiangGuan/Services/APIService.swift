//
//  APIService.swift
//  ZhaoXiangGuan
//
//  API 服务层 - AI生成/用户/支付
//

import Foundation
import UIKit

// API 配置
struct APIConfig {
    static let baseURL = "https://api.zhaoxiangguan.com" // 替换为实际的API地址
    static let timeout: TimeInterval = 30.0
}

// API 错误类型
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case serverError(code: Int, message: String)
    case decodingError
    case encodingError
    case unauthorized
    case insufficientPoints

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的请求地址"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .invalidResponse:
            return "无效的响应"
        case .serverError(_, let message):
            return message
        case .decodingError:
            return "数据解析失败"
        case .encodingError:
            return "数据编码失败"
        case .unauthorized:
            return "未授权，请先登录"
        case .insufficientPoints:
            return "积分不足"
        }
    }
}

// API 服务类
class APIService {
    static let shared = APIService()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConfig.timeout
        self.session = URLSession(configuration: configuration)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - 通用请求方法

    private func performRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 添加认证token（如果有）
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 添加请求体
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                completion(.failure(.encodingError))
                return
            }
        }

        // 执行请求
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            // 处理HTTP状态码
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                completion(.failure(.unauthorized))
                return
            case 402:
                completion(.failure(.insufficientPoints))
                return
            case 400...499:
                if let data = data,
                   let errorResponse = try? self.decoder.decode(ErrorResponse.self, from: data) {
                    completion(.failure(.serverError(code: httpResponse.statusCode, message: errorResponse.message)))
                } else {
                    completion(.failure(.serverError(code: httpResponse.statusCode, message: "请求失败")))
                }
                return
            case 500...599:
                completion(.failure(.serverError(code: httpResponse.statusCode, message: "服务器错误")))
                return
            default:
                completion(.failure(.invalidResponse))
                return
            }

            // 解析响应数据
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let result = try self.decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }

    // MARK: - AI 生成相关

    /// 生成艺术照
    func generateArtisticImage(
        request: ImageGenerationRequest,
        completion: @escaping (Result<ImageGenerationResponse, APIError>) -> Void
    ) {
        performRequest(endpoint: "/api/v1/generate", method: .post, body: request, completion: completion)
    }

    /// 重新生成图片
    func regenerateImage(
        request: ImageRegenerationRequest,
        completion: @escaping (Result<ImageGenerationResponse, APIError>) -> Void
    ) {
        performRequest(endpoint: "/api/v1/regenerate", method: .post, body: request, completion: completion)
    }

    // MARK: - 用户相关

    /// 发送验证码
    func sendVerificationCode(
        request: VerificationCodeRequest,
        completion: @escaping (Result<VerificationCodeResponse, APIError>) -> Void
    ) {
        performRequest(endpoint: "/api/v1/auth/code", method: .post, body: request, completion: completion)
    }

    /// 手机号登录/注册
    func loginWithPhone(
        request: PhoneLoginRequest,
        completion: @escaping (Result<LoginResponse, APIError>) -> Void
    ) {
        performRequest(endpoint: "/api/v1/auth/phone", method: .post, body: request, completion: completion)
    }

    /// 第三方登录
    func loginWithThirdParty(
        request: ThirdPartyLoginRequest,
        completion: @escaping (Result<LoginResponse, APIError>) -> Void
    ) {
        performRequest(endpoint: "/api/v1/auth/third-party", method: .post, body: request, completion: completion)
    }

    // MARK: - 积分相关

    /// 获取用户积分余额
    func getUserPoints(
        completion: @escaping (Result<PointsResponse, APIError>) -> Void
    ) {
        performRequest(endpoint: "/api/v1/points", method: .get, completion: completion)
    }

    /// 创建支付订单
    func createPaymentOrder(
        request: CreateOrderRequest,
        completion: @escaping (Result<OrderResponse, APIError>) -> Void
    ) {
        performRequest(endpoint: "/api/v1/orders", method: .post, body: request, completion: completion)
    }

    /// 查询订单状态
    func checkOrderStatus(
        orderId: String,
        completion: @escaping (Result<OrderStatusResponse, APIError>) -> Void
    ) {
        performRequest(endpoint: "/api/v1/orders/\(orderId)/status", method: .get, completion: completion)
    }
}

// MARK: - HTTP 方法

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - 请求模型

/// 图片生成请求
struct ImageGenerationRequest: Encodable {
    let image: String // Base64 编码的图片
    let style: String // 风格名称
    let userId: String
}

/// 图片重新生成请求
struct ImageRegenerationRequest: Encodable {
    let generationId: String
    let userId: String
}

/// 验证码请求
struct VerificationCodeRequest: Encodable {
    let phoneNumber: String
}

/// 手机号登录请求
struct PhoneLoginRequest: Encodable {
    let phoneNumber: String
    let verificationCode: String
}

/// 第三方登录请求
struct ThirdPartyLoginRequest: Encodable {
    let provider: String // "wechat", "apple"
    let code: String // 授权码
    let userId: String // 第三方用户ID
}

/// 创建订单请求
struct CreateOrderRequest: Encodable {
    let tier: String
    let amount: Int
    let paymentMethod: String // "wechat", "alipay", "apple_pay"
}

// MARK: - 响应模型

/// 错误响应
struct ErrorResponse: Decodable {
    let message: String
    let code: String?
}

/// 图片生成响应
struct ImageGenerationResponse: Decodable {
    let generationId: String
    let imageUrl: String
    let status: String
    let watermarkUrl: String // 带水印的图片URL
}

/// 验证码响应
struct VerificationCodeResponse: Decodable {
    let success: Bool
    let message: String
    let expiresAt: Int?
}

/// 登录响应
struct LoginResponse: Decodable {
    let success: Bool
    let token: String?
    let userId: String
    let phoneNumber: String?
    let points: Int?
    let message: String
}

/// 积分响应
struct PointsResponse: Decodable {
    let points: Int
    let updatedAt: Double
}

/// 订单响应
struct OrderResponse: Decodable {
    let orderId: String
    let amount: Int
    let points: Int
    let paymentUrl: String? // 支付链接（某些支付方式需要）
    let expiresAt: Int
}

/// 订单状态响应
struct OrderStatusResponse: Decodable {
    let orderId: String
    let status: String // "pending", "paid", "failed", "cancelled"
    let pointsAdded: Int?
}
