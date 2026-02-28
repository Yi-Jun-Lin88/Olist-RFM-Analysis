# 2026/02/21（六）
# 零件探索： 先確認各表內容，測試 R、F、M 的邏輯
use resume_data;

# 針對 olist_orders_dataset 獲取訂單狀態（過濾取消的訂單）＆購買時間
# 獲取訂單狀態並過濾掉"取消"的訂單
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp AS purchase_time
FROM
    olist_orders_dataset
WHERE
    order_status <> 'canceled';

# 計算購買時間（數據集中最新日期～訂單日期之間的天數差
SELECT
    customer_id,
    MAX(order_purchase_timestamp) AS last_purchase_date,
    DATEDIFF(
        (SELECT MAX(order_purchase_timestamp) FROM olist_orders_dataset),
        MAX(order_purchase_timestamp)
    ) AS recency_days
FROM
    olist_orders_dataset
WHERE
    order_status != 'canceled'
GROUP BY
    customer_id;

# 針對 olist_order_items_dataset 獲取消費金額＆購買頻率
SELECT
    ois.customer_id,
    COUNT(DISTINCT ois.order_id) AS frequency, # Frequency (頻率)：計算該客戶總共有多少個「不重複的訂單 ID」（回購次數
    # DISTINCT 確保一筆訂單只被計算一次；購買頻率 ➡️ 回購次數（而非購買件數
    SUM(oi.price) AS monetary # Monetary (金額): 累加該客戶所有訂單明細中的價格
    # 若想包含運費應寫為 SUM(oi.price + oi.freight_value)
FROM
    olist_orders_dataset as ois
JOIN
    olist_order_items_dataset oi ON ois.order_id = oi.order_id
    # 透過兩張表各自的 order_id 進行表間關聯
WHERE
    ois.order_status <> 'canceled'
GROUP BY
    ois.customer_id;

# 針對 olist_customers_dataset 獲取客戶的唯一識別碼
SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM
    olist_orders_dataset o
JOIN
    olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE
    o.order_status != 'canceled';

# 製作一張乾淨的寬表 (Wide Table)
# 包含：customer_unique_id、order_purchase_timestamp、payment_value (商品價格 + 運費)
# 並使用 WHERE 排除掉 order_status 為 'canceled' 或 'unavailable' 的無效訂單
SELECT
    c.customer_unique_id,               # 客戶唯一識別碼
    o.order_purchase_timestamp,         # 購買時間
    p.payment_value                     # 支付總金額 (通常已含商品價格 + 運費)
FROM
    olist_orders_dataset o
    # 串接客戶表：為了拿到真正的客戶 ID
JOIN
    olist_customers_dataset c ON o.customer_id = c.customer_id
    # 串接支付明細表：為了拿到該筆訂單的總支付金額
JOIN
    olist_order_payments_dataset p ON o.order_id = p.order_id
    # 過濾條件：排除無效訂單
WHERE
    o.order_status NOT IN ('canceled', 'unavailable');


SELECT
    c.customer_id,                      # 客戶 ID
    c.customer_unique_id,               # 客戶唯一識別碼
    o.order_id,                         # 訂單 ID
    o.order_purchase_timestamp,         # 購買時間
    # 匯出 購買時間 比匯出 計算出的購買天數 更有價值
    items.price,                        # 該訂單的純商品總價
    items.freight_value,                # 該訂單的總運費
    # 商品金額+運費
    (items.price + items.freight_value) AS original_total,
    p.payment_value,                    # 該訂單的實際總支付金額 (含折扣/運費)
    # 差額 (正數為手續費/利息，負數為折扣)
    (p.payment_value - (items.price + items.freight_value)) AS adjustment_value
FROM
    olist_orders_dataset o
    # 串接客戶表：為了拿到真正的客戶 ID
JOIN
    olist_customers_dataset c ON o.customer_id = c.customer_id
    # 串接支付明細表：為了拿到該筆訂單的總支付金額
JOIN # 使用子查詢預先加總支付金額，避免數據膨脹
    (SELECT order_id, SUM(payment_value) AS payment_value # 客戶實際總支付金額
     FROM olist_order_payments_dataset
     GROUP BY order_id) p ON o.order_id = p.order_id
JOIN # 對 items 進行預先加總，確保「一單一行」
    (SELECT order_id,
            SUM(price) AS price,
            SUM(freight_value) AS freight_value
     FROM olist_order_items_dataset
     GROUP BY order_id) items ON o.order_id = items.order_id
WHERE
    o.order_status NOT IN ('canceled', 'unavailable');

# 建立寬表： 將所有乾淨的、過濾後的「原始事實」串接在一起（類似「數據中台」的概念
# 串接在一起後，方便匯出後在 Python 進行操作
