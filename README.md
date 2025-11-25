Retail Sales Intelligence Dashboard
Python → SQL → Power BI | 128,975 Orders | ₹78.5M Revenue

This project delivers an end-to-end Retail Sales Intelligence System that analyses sales performance, category contribution, fulfilment reliability, and operational revenue leakage for an e-commerce apparel business.
The workflow spans data cleaning (Python) → data validation (SQL) → data visualization (Power BI).

1. Project Summary

Dataset size: 128,975 rows

Total Orders: 120,378

Total Revenue: ₹78,592,678

Period: Mar–Jun 2022

Tools: Python (pandas), MySQL, Power BI

Output: 3-page executive dashboard + insights + recommendations

2. Key Insights
✔ Revenue Concentration

Just 2 categories (Set, Kurta) contribute ₹6 Cr+ → high dependence on core products.

✔ Fulfilment Impact

Amazon fulfilment shows significantly lower cancellations vs Merchant fulfilment.

✔ Revenue Leakage

18,332 cancellations (14.21%)

Only 2,098 returns → most revenue loss occurs before delivery.

✔ Geographic Demand

Strong clustering in Bengaluru, Hyderabad, Mumbai, Chennai, Delhi.

✔ Category Sensitivity

Western Dress & Ethnic Dress show higher return/cancellation patterns → likely due to size/fit issues.

3. Dashboard Features

Page 1: Sales Performance Overview

Page 2: Category & Fulfilment Analytics

Page 3: Order Journey, Cancellations, Returns, Lost Revenue

4. Recommendations

Shift top categories to Amazon fulfilment for higher delivery success.

Improve size guides & product details for apparel.

Tighten order confirmation process to reduce mid-funnel cancellations.

Use address validation at checkout (state cleanup revealed quality issues).

Prioritize inventory in South & West India for faster movement.

5. Caveats

Data covers only 3 months (seasonality unknown).

No customer-level segmentation.

Some state/region inconsistencies cleaned manually.

Fulfilment tagging assumed accurate.

6. Tech Stack

Python (Pandas)

MySQL

Power BI

DAX

ERD / Data Modeling
