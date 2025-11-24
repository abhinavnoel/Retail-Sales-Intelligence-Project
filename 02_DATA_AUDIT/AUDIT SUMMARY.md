**1. DATASET OVERVIEW**

This dataset contains **128,975 rows** and **24 columns** from an e-commerce retail operation. 

It represents the complete order lifecycle including order creation, shipping, delivery, returns, cancellations, fulfilment methods, promotions, and location attributes.

The data behaves like a line-level transactional dataset, meaning each row represents a unique item within a customer’s order (multi-item orders share the same Order ID).

The dataset allows analysis across:

	1. Fulfilment Performance

	2. Returns And Cancellations

	3. Shipping Delays

	4. Customer Geography

	5. Promotional Impact

	6. Revenue Leakage

	7. SKU And Category-Level Behaviour

This audit documents data quality issues, structural patterns, missing values, and transformation requirements before cleaning and modelling.



**2. MISSING VALUE ANALYSIS**

A column-wise missing value review shows that the dataset has significant null patterns in several fields, especially operational and promotion-related columns. 

***Key findings:***

*COLUMNS WITH HIGH MISSING VALUES*

	1. Fulfilled-by — 89,698 missing

	2. Promotion-ids — 49,153 missing

	3. Amount — 7,795 missing

	4. Currency — 7,795 missing

	5. Courier Status — 6,872 missing

These fields indicate either incomplete tracking by the operational systems or optional data captured only in specific scenarios (e.g., promotions, courier updates).

*COLUMNS WITH SMALL BUT RELEVANT MISSING VALUES*

	1. ship-city — 33 missing

	2. ship-state — 33 missing

	3. ship-postal-code — 33 missing

	4. ship-country — 33 missing

Although the volume is small, these fields are critical for geography-based analytics and will need attention during cleaning.

COLUMNS WITH MINIMAL OR NO MISSING VALUES

Most categorical fields such as Status, Fulfilment, Sales Channel, Size, and Category are complete and usable.

**Conclusion:**
The dataset contains a mix of high-criticality and low-criticality missingness. 
High-null columns require strategic decision-making (retain, impute, or drop), while low-null location columns require targeted fixes.



**3. DUPLICATE ANALYSIS**

A duplicate audit was performed at both the row level and the Order ID level to understand data uniqueness.

*Row-Level Duplicate Check*

A check for fully duplicated rows returned **0** duplicates.

This confirms that no identical records exist at the row level.

*Order ID-Level Observations*

Multiple rows share the same Order ID.

This is expected behaviour for this dataset because it represents line-level transactions:

One customer order may contain multiple SKUs, each recorded as a separate row.

Therefore, repeated Order IDs do not indicate data duplication; they reflect multi-item orders.

**Conclusion**

No data duplication issues exist at the row level.

Order ID repetition is normal and required for granular order-line analytics.



**4. CATEGORY-LEVEL OBSERVATIONS**

A review of key categorical fields revealed several inconsistencies, mixed granularities, and formatting issues. 
These require standardization before use in analytics or modelling.

***Status***

	1. Displays mixed granularity (e.g., “Shipped”, “Shipping”, “Delivered”, “Return Initiated”, “Picked Up”).

	2. Contains both states and events, making the category non-uniform.

	3. Needs consolidation into a smaller set of core lifecycle states.

***Promotion-ids***

	1. Contains multiple promotion codes in a single cell (comma-separated).

	2. Presence of trailing whitespace and inconsistent formatting.

	3. Extremely high unique combinations (~5,787).

	4. 49,153 nulls, meaning promotions were applied selectively.

	5. Requires:

		a.parsing/splitting

		b.trimming whitespace

		c.possibly generating a promo_count field.

***Category***

	1. Inconsistent casing (e.g., “kurta”, “Set”).

	2. Requires case normalization for clean grouping.

***Courier Status***

	1. Contains many nulls.

	2. Needs consolidation and null handling.

***Fulfilment***

	1. Values appear inconsistent or incomplete due to high missingness in related fields (e.g., fulfilled-by).

	2. Requires standardization across shipping methods (e.g., “Amazon”, “Easy Ship”, “Merchant”).

***Size & Other Categorical Fields***

	1. Generally clean but may contain hidden whitespace.

	2. Require trimming and consistent formatting.

**Conclusion:**
Categorical fields need extensive normalization (case, whitespace, category mapping, and granularity reduction) for reliable analytics and modelling.



**5. NUMERIC FIELD OBSERVATIONS**

A detailed audit of the numeric fields (primarily Amount, Qty) revealed the following patterns and issues:

***Amount***

	1. Contains 2,343 zero values, which may represent:

		a.free items,

		b.refunded transactions, or

		c.missing/invalid prices incorrectly recorded as 0.

	2. Stored as object type, indicating numeric values mixed with non-numeric formatting.

	3. Requires:

		a.conversion to float,

		b.validation of zeros,

		c.removal of non-numeric artifacts (e.g., commas).

***currency***

	1. Shares the same missingness pattern as Amount, with 7,795 nulls.

	2. Must be validated to confirm consistent currency (e.g., INR).

	3. Needs standardization and type conversion.

***Qty***

	1. Numeric values appear valid, but must be checked for:

		a.negative quantities,

		b.abnormally high quantities.

	2. Likely requires type enforcement to int.

***General Numeric Issues***

	1. Several numeric columns are stored as objects due to mixed formatting.

	2. Potential presence of:

	3. whitespace,

	4. text tokens,

	5. inconsistent separators (e.g., commas in numbers).

**Conclusion:**
Numeric fields require **standardization, type correction, outlier inspection, and validation** before they can be used for revenue, margin, or operational analytics.



**6. DATE OBSERVATIONS**

A review of the Date column shows that the dataset’s temporal information is largely consistent and clean, with only formatting and type issues to address before analysis.

**Date Range**

	1. Dates fall within a reasonable and realistic business period.

	2. No evidence of:

		a.future dates,

		b.impossible years

		c.abnormal spikes.

**Format Consistency**

	1. All values appear to follow a consistent date format, with no mixed styles detected.

	2. No invalid strings or parsing failures were found when converting to datetime.

**Data Type**

	1. Currently stored as object/string, not as a proper datetime type.

	2. Requires conversion to datetime64 during cleaning.

**Missing Values**

	1.  No significant missingness identified in the Date field.

**Temporal Relationship (to be validated later)**

	1. Since this dataset represents the full order lifecycle, additional checks may be needed after creating derived timestamps 
	   (e.g., ship date vs. delivered date vs. returned date) if more date fields are added in later stages.

**Conclusion:**
Date fields are structurally healthy but require dtype conversion and integration with additional lifecycle dates if available.



**7. STRUCTURAL ISSUES**

Several structural inconsistencies and non-analytic fields were identified during the audit. 
These must be addressed before cleaning and modelling to ensure a stable data schema and reliable downstream analysis.

***Unnamed or Empty Columns***

	1. The dataset contains at least one unnamed column (e.g., Unnamed: 22) with ~49,000 null values.

	2. This column provides no analytical value and is a strong candidate for removal.

***fulfilled-by***

	1. Contains 89,698 nulls, indicating incomplete or inconsistent tracking.

	2. The column is likely redundant due to other fulfilment-related columns.

	3. Requires:

		a.deeper inspection,

		b.potential dropping, or

		c.consolidation into a unified fulfilment field.

***Multi-item Orders***

	1. Repeated Order ID values indicate line-level granularity, not order-level.

	2. This affects:

		a.groupby logic,

		b.revenue calculations,

		c.Power BI modelling (Fact table vs Dim tables).

***Inconsistent Column Naming Conventions***

	1. Certain columns use hyphens (ship-city, ship-state, promotion-ids) instead of snake_case.

	2. Standardization to ship_city, ship_state, etc., will improve readability and downstream processing.

***Mixed-Type Columns***

	1. Several fields expected to be numeric (e.g., Amount, currency) are stored as object due to formatting.

	2. These require type correction and validation before aggregation or modelling.

***High-Cardinality Columns***

	1. Columns such as promotion-ids, ASIN, and SKU contain a large number of unique values.

	2. May require:

		a. normalizing,

		b. splitting,

		c. deriving counts,

		d. or creating hierarchies to make analysis meaningful.

***Whitespace & Hidden Characters***

	1. Preliminary inspection indicates the presence of:

		a. trailing/leading spaces,

		b. inconsistent casing,

		c. potentially hidden formatting characters in text fields.

These issues must be cleaned to avoid duplicate categories and grouping errors.



**8. DERIVED COLUMNS NEEDED**

Based on the audit findings and the structure of the dataset, several new fields must be created to support analytics, modelling, fulfilment performance evaluation, and revenue impact calculations. 
These derived columns will become part of the cleaned master dataset.

Note: Only fields supported directly by the dataset will be created. No business assumptions (profit, cost, or delivery delay estimation) will be introduced.


***1. Return_Flag***

	1. 1 if the order line was returned

	2. 0 otherwise

	3. Enables return-rate analysis at SKU, category, and geography levels

***2. Cancel_Flag***

	1. 1 if the order line was cancelled

	2. 0 otherwise

	3. Helps identify cancellation hotspots and fulfilment issues

***3. Promo_Flag***

	1. 1 if the promotion-ids field is non-null

	2. 0 if no promotion was applied

	3. Supports promo impact, margin analysis, and leakage modelling

***4. Promo_Count***

	1. Number of promotion codes applied

	2. Useful when promotions have multiple layers (stacked discounts)

***5. SLA_breach_flag***

	1. 1 if the delivery time exceeds standard SLA

	2. 0 otherwise

	3. Supports fulfilment performance dashboards

***6. Fulfilment_Normalized***

	1. Standardized version of fulfilment values (e.g., Amazon, Easy Ship, Merchant)

	2. Fixes inconsistent casing and missing labels

***7. Shipping_Level_Normalized***

	1. Standardizes values like "Standard", "Expedited", etc.

	2. Helpful for shipping cost modelling and what-if analysis

***8. Category_Clean***

	1. Case-normalized version of Category

	2. Ensures clean grouping and pivoting in analytics

***9. City_Clean, State_Clean***

	1. Trimmed and standardized versions of location fields

	2. Required for geography-based analysis in dashboards

**Conclusion:**
These derived fields form the foundation for return modelling, promo analytics, fulfilment efficiency analysis, and the final Power BI simulation engine. 
They will be added during the cleaning and transformation steps.



**9. FINAL PROBLEM LIST**

The following issues were identified during the dataset audit and must be addressed during cleaning and transformation:

***Data Quality Issues***

	1. Significant missing values in multiple columns (fulfilled-by, promotion-ids, Amount, currency, Courier Status).

	2. Missing entries in location fields (ship-city, ship-state, ship-postal-code, ship-country).

	3. Zero-value entries present in numeric fields (Amount, Qty).

***Structural Issues***

	1. Unnamed column (Unnamed: 22) with no analytical value.

	2. Dataset shows line-level granularity (repeated Order ID values for multi-item orders).

	3. Inconsistent column naming conventions (hyphens, mixed casing).

	4. High-cardinality fields (promotion-ids, ASIN, SKU) require careful handling.

***Category Inconsistencies***

	1. Status contains mixed granularity and redundant variations.

	2. Category has inconsistent casing.

	3. promotion-ids contains multi-value entries, trailing whitespace, and over 5,700 unique combinations.

	4. Courier Status is incomplete and inconsistently populated.

***Numeric Issues***

	1. Amount and currency stored as object types due to mixed formatting.

	2. Zero values may represent invalid or missing data.

	3. Possible formatting artifacts (commas, hidden characters).

***Date Issues***

	1. Date stored as object instead of datetime64.

	2. No invalid or future dates detected, but conversion is required.

***Text Formatting Issues***

	1. Possible presence of leading/trailing whitespace, mixed casing, inconsistent formatting across text fields.

***Columns Requiring Standardization***

	1. ship-city, ship-state, ship-postal-code, ship-country

	2. Fulfilment

	3. Sales Channel

	4. Category

	5. Status

	6. promotion-ids

***Derived Fields Needed***

	1. return_flag

	2. cancel_flag

	3. promo_flag

	4. promo_count

	5. fulfilment_normalized

	6. shipping_level_normalized

	7. category_clean

	8. city_clean, state_clean