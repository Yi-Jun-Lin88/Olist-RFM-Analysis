# 📊 巴西電商 Olist 客群分群與商業價值分析 (RFM Analysis)
## 🎯 專案簡介（Project Overview）
本專案基於真實世界的巴西 Olist 電商數據（約 10 萬筆訂單），利用 SQL 進行多表關聯與資料萃取，並透過 Python 建構 RFM 模型，對客戶進行價值分群。最終產出 Power BI 商業儀表板，為行銷團隊提供具體的受眾標籤與挽留策略。

## 🛠 核心技術（Tech Stack）
- 資料庫萃取： MySQL (`JOIN`, Subqueries, Data Aggregation)
- 數據清洗與運算： Python (`pandas`, `numpy`, `itertools`)
- 視覺化與商業洞察： Power BI

## 📝 專案亮點與核心邏輯
【Situation：情境】
原始資料散落於 9 張關聯表中，包含退貨、取消訂單及極端消費金額等真實商業雜訊，且高達 90% 以上的客戶僅消費過一次，導致傳統分位數演算法失效。

【Task：任務】
在 9 張關聯表中選取 3 張關聯表，從中建立一條資料管線，清洗無效數據，並計算每位獨立訪客的 RFM 價值，最終將生硬的數字轉化為業務端能直接使用的行銷名單。

【Action：行動】
- SQL 防錯機制： 在多表 `JOIN` 前，先使用子查詢 (Subquery) 預先加總商品明細與支付金額，成功避免多對多關聯導致的「資料膨脹 (Cartesian Product)」計算錯誤。
- 效能優化工程： 捨棄傳統的 `apply` 逐行運算，利用 Python 建構「125 種 RFM 組合映射底稿 (Mapping Table)」，改以 `merge` 進行標籤關聯，大幅降低時間複雜度，提升大數據運算效能。
- 商業洞察雙軌制： 在利用 IQR (四分位距) 清洗異常值的過程中，發現被剔除的「極端值」實為貢獻公司極高營收的「Champions 冠軍客群/頂級 VIP (Whales)」。因此保留 Raw 與 Cleaned 兩組數據進行對照分析。

【Result：結果】
成功將 10 萬名客戶精準劃分為「頂級 VIP」、「潛力新客」、「流失危機客」等 8 大商業客群，並產出商業儀表板，賦能行銷單位進行精準的廣告投放與預算分配。

## 📈 商業儀表板展示 (Dashboard Preview)
<p align="center">
<img width="500" alt="Github - Olist RFM Analysis 所需圖表" src="https://github.com/user-attachments/assets/4950c8bc-1435-4ff0-ab1d-9c92a71d0b56" />
</p>

## 🏗️ 檔案結構 (Repository Structure)
```text
.
├── src/                                                  # 原始程式碼
│   ├── console_2.sql
│   └── Brazilian E-Commerce Public Dataset.ipynb
├── data/                                                 # 數據
│   ├── READ.md                                           # 原始數據
│   └── olist_customers_orders_items_dataset_new.csv      # MySQL 撈出的寬表數據
└── README.md
