-- 造像馆积分系统数据库初始化脚本

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone VARCHAR(20) UNIQUE NOT NULL,
    nickname VARCHAR(100),
    avatar VARCHAR(500),
    points INTEGER DEFAULT 100,  -- 新用户注册赠送100积分
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 积分记录表
CREATE TABLE IF NOT EXISTS point_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    type VARCHAR(20) NOT NULL,  -- 'earn' 获得, 'spend' 消费, 'recharge' 充值
    amount INTEGER NOT NULL,     -- 积分数量（正数为获得，负数为消费）
    description VARCHAR(200),
    related_id VARCHAR(100),    -- 关联ID（如订单号、生成记录ID等）
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 充值套餐表
CREATE TABLE IF NOT EXISTS recharge_packages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    price DECIMAL(10,2) NOT NULL,     -- 价格（元）
    points INTEGER NOT NULL,          -- 积分数量
    bonus_points INTEGER DEFAULT 0,   -- 赠送积分
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 充值订单表
CREATE TABLE IF NOT EXISTS recharge_orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id VARCHAR(50) UNIQUE NOT NULL,  -- 订单号
    user_id INTEGER NOT NULL,
    package_id INTEGER,
    amount DECIMAL(10,2) NOT NULL,         -- 支付金额
    points INTEGER NOT NULL,               -- 获得积分
    bonus_points INTEGER DEFAULT 0,        -- 赠送积分
    status VARCHAR(20) DEFAULT 'pending',  -- 'pending' 待支付, 'paid' 已支付, 'failed' 失败
    payment_method VARCHAR(50),
    paid_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (package_id) REFERENCES recharge_packages(id)
);

-- 图片生成记录表
CREATE TABLE IF NOT EXISTS generation_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    style VARCHAR(50),           -- 主风格
    substyle VARCHAR(50),        -- 子风格
    prompt TEXT,                 -- 使用的提示词
    input_image VARCHAR(500),    -- 输入图片URL
    output_image VARCHAR(500),   -- 输出图片URL
    points_cost INTEGER DEFAULT 20,  -- 消耗积分
    status VARCHAR(20) DEFAULT 'success',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 插入充值套餐数据（充的越多送越多，最多20%）
INSERT INTO recharge_packages (price, points, bonus_points, sort_order) VALUES
(30, 300, 0, 1),         -- 30元300积分（0%赠送）
(100, 1000, 100, 2),     -- 100元1100积分（10%赠送）
(300, 3000, 450, 3),     -- 300元3450积分（15%赠送）
(1000, 10000, 2000, 4);  -- 1000元12000积分（20%赠送）

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_point_records_user_id ON point_records(user_id);
CREATE INDEX IF NOT EXISTS idx_recharge_orders_user_id ON recharge_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_recharge_orders_order_id ON recharge_orders(order_id);
CREATE INDEX IF NOT EXISTS idx_generation_records_user_id ON generation_records(user_id);
