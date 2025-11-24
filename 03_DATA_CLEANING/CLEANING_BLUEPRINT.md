**1. Purpose of the Cleaning Blueprint**

This document defines the complete, step-by-step plan for transforming the raw dataset into a clean, standardized, and analysis-ready master dataset. It translates the findings from the Data Audit into clear cleaning rules, ensuring that every modification is intentional, reproducible, and aligned with BI best practices.

The blueprint acts as the bridge between **Audit → Cleaning Code → Final Dataset**, and ensures that all cleaning operations follow a structured, documented, and consistent approach.



**2. Columns to Drop**

Based on the audit findings, the following columns provide no analytical value or contain excessive missingness, making them unsuitable for inclusion in the cleaned master dataset:

***Columns to Remove***

    1. Unnamed: 22

        a. Contains ~49,000 null values.

        b. No business meaning or usable information.

        c. Safe to drop entirely.

    2. fulfilled-by

        a. Contains ~89,698 null values.

        b. Overlaps with other fulfilment-related fields.

        c. Provides inconsistent or incomplete information.

        d. Will be removed to avoid noise in modelling and dashboards.

***Rationale***

Dropping these columns ensures the cleaned dataset remains lean, meaningful, and free of redundant or unusable attributes that could introduce errors into analysis or Power BI modelling.



**3. Columns to Rename / Standardize**

To ensure consistency, readability, and smooth downstream processing, the following columns will be renamed using *snake_case* and standardized naming conventions. This also helps maintain uniformity across SQL, Python, and Power BI layers.

Columns to Rename

| Original Column Name | Standardized Name  | Reason                                                 |
| -------------------- | ------------------ | ------------------------------------------------------ |
| `ship-city`          | `ship_city`        | Replace hyphens with underscores for consistency       |
| `ship-state`         | `ship_state`       | Standardized naming convention                         |
| `ship-postal-code`   | `ship_postal_code` | Avoid hyphens and improve readability                  |
| `ship-country`       | `ship_country`     | Match other geographic field names                     |
| `promotion-ids`      | `promotion_ids`    | Required for splitting and analysis                    |
| `Sales Channel`      | `sales_channel`    | Standardize capitalization & spacing                   |
| `Qty`                | `quantity`         | More descriptive, consistent                           |
| `Status`             | `status`           | Lowercase for consistent text processing               |
| `Category`           | `category`         | Lowercase for uniformity                               |
| `Courier Status`     | `courier_status`   | Remove space and standardize                           |
| `Fulfilment`         | `fulfilment`       | Lowercase for categorization consistency               |
| `Date`               | `order_date`       | Adds clarity and prepares for future multi-date fields |


***Rationale***

    1. Standardized column names eliminate inconsistencies.

    2. Ensures compatibility with pandas, SQL, and Power BI modelling.

    3. Helps avoid errors caused by hyphens, spaces, and mixed casing.

    4. Improves code readability and documentation quality.




**4. Data Type Corrections**

This section lists every column that requires a dtype correction or parsing rule. For each column we state the target dtype, the transformation rules, and acceptance criteria to validate the correction.

***4.1 order_date***

    a. Target dtype: datetime64[ns]

    b. Transformation rules: parse strings into datetime using a robust parser; trim whitespace first; use strict parsing where format is known, otherwise fallback with errors='coerce'.

    c. Acceptance criteria: min/max date sensible for business period; conversion rate ≥ 99.9% (very few NaTs); no future dates.

***4.2 amount***

    a. Target dtype: float

    b. Transformation rules: remove currency symbols, commas, and non-numeric characters; trim whitespace; convert to float; treat empty strings and obvious placeholders as NaN.

    c. Acceptance criteria: dtype is numeric; percent non-null after conversion matches expectation from audit (account for originally missing values); no non-numeric artifacts remain.

***4.3 currency***

    a. Target dtype: categorical / string (normalized)

    b. Transformation rules: trim, uppercase (e.g., INR), map variants to canonical codes; mark missing explicitly as NULL/NaN.

    c. Acceptance criteria: unique currency codes are canonical (e.g., INR); missingness unchanged except converted to proper null type.

***4.4 quantity***

    a. Target dtype: integer (int) or nullable integer if missing values exist

    b. Transformation rules: remove non-numeric characters, coerce to integer; investigate negative or zero values per numeric rules.

    c. Acceptance criteria: dtype integer or nullable-int; no non-integer values remain.

***4.5 ship_charge / any shipping cost fields***

    a. Target dtype: float

    b. Transformation rules: same cleaning as amount (remove symbols/commas, convert to float).

    c. Acceptance criteria: numeric dtype; distribution matches expected shipping values (no obviously malformed large strings).

***4.6 promotion_ids***

    a. Target dtype: string for master field; separate exploded promotion_id table/list as derived structure (see blueprint derived steps)

    b. Transformation rules: trim whitespace, remove trailing commas, standardize delimiters; keep master field as cleaned string and create parsed list/array in cleaning output or separate promotion mapping table.

    c. Acceptance criteria: master promotion_ids contains normalized comma-separated tokens (no empty tokens), and a parsed list column or separate table exists for promo-level analysis.

***4.7 status, fulfilment, courier_status, sales_channel, category, size***

    a. Target dtype: categorical / string (normalized)

    b. Transformation rules: trim whitespace, convert to lowercase (or apply mapping to canonical labels), remove control characters, apply mapping table for known synonyms (e.g., “Shipped” / “shipping” → shipped).

    c. Acceptance criteria: categories reduced to canonical set per mapping; no leading/trailing whitespace; no hidden characters.

***4.8 Location fields (ship_city, ship_state, ship_postal_code, ship_country)***

    a. Target dtype: string (trimmed) for city/state/country; string or int for postal code depending on format

    b. Transformation rules: trim, remove non-printable characters, normalize common country names/codes, ensure postal code preserved as string if it can contain leading zeros.

    c. Acceptance criteria: no leading/trailing spaces; postal codes preserved accurately (no dropped leading zeros).

***4.9 Any unnamed/auxiliary columns to be dropped***

    a. Target dtype: N/A — drop as per Section 2.

**General conversion rules and notes**

    a. Whitespace & hidden characters: always trim and remove non-printable characters from string fields prior to conversion.

    b. Error handling: conversions should use a coercion strategy where invalid values become NaN/NaT rather than throwing; preserve a log or sample of coerced values for review.

    c. Null semantics: ensure NaN / NaT are used consistently for missing numeric/date values; use None/NaN for missing strings.

    d. Versioning: save an intermediate clean_stepX file after dtype corrections with statistics summarizing the number of coerced values per column. This will be used for validation tests.

**Validation / Acceptance tests (post-conversion)**

List these checks as acceptance criteria to run after dtype corrections:

    1. No object dtype remains for columns listed above where a numeric/date type is expected.

    2. Percent converted: for amount and order_date, conversion success rate should be ≥ 99% given original audit missingness; document exceptions.

    3. No future dates in order_date.

    4. Numeric range checks: amount and ship_charge should not contain extreme outliers beyond business plausibility without manual inspection.

    5. Promotion_ids parsing: parsed promo list has no empty tokens; token count matches cleaned promotion_ids semantics.

    6. Categorical mapping: canonical category count should be substantially fewer than raw distinct values (evidence of normalization).




**5. Missing Value Strategy**

This section defines the handling rules for each column with missing values, based directly on the audit findings. 
The goal is to ensure that missingness is treated consistently, transparently, and without introducing unjustified assumptions.

***5.1 High-Missingness Columns***

fulfilled-by

    Missing ~89,698 entries (very high).

    Column carries incomplete/low-quality operational data.

    Strategy: Drop the column entirely (already listed in Columns to Drop).

promotion_ids

    Missing ~49,153 entries.

    Missingness is meaningful (no promotion applied).

    Strategy:

        Keep the field.

        Treat missing as “no promotion applied.”

        Set promo_flag = 0 for null values.

        Leave promotion_ids as null/empty for non-promotional rows.

***5.2 Medium-Missingness Columns***

amount & currency

    Missing ~7,795 entries.

    Missing amount = missing revenue; missing currency = incomplete transaction.

Strategy:

    Retain rows; do not impute with zero or median.

    Keep missing as NaN.

    Document records where amount is missing but quantity exists (for investigation).

    currency missing → treat as null; no assumptions.

courier_status

    Missing ~6,872 entries.

    Indicates missing tracking updates.

    Strategy:

        Keep nulls.

        Do not fill or impute.

        Normalize non-null values but allow missingness to remain as a valid category.

***5.3 Low-Missingness Columns***

Location fields:

    ship_city, ship_state, ship_postal_code, ship_country (~33 missing each).

    Strategy:

        Keep nulls as null.

        Do not impute because location-specific assumptions can distort analysis.

        Apply text cleaning to non-null values.

***5.4 General Missing Value Rules***

    Never replace missing values with arbitrary placeholders (e.g., “Unknown”).

    Use NaN/None consistently for missing textual and numeric data.

    Use NaT for missing dates (if any occur during conversion).

    Document the number of missing values before and after cleaning for validation.

    Missingness itself can be used as a signal (e.g., promo_flag, courier_status quality).

***5.5 Post-Cleaning Validation***

After cleaning missing values:

    Recompute missing-value counts for all fields.

    Validate that dropped columns are removed.

    Confirm that no unwanted auto-imputed values (zeros, empty strings) appear.

    Ensure promotion_ids retains nulls logically.

    Verify location fields only lost whitespace, not content.



**6. Category Normalization Rules**

All categorical/text fields will be standardized to ensure consistency and clean grouping across the dataset.

***6.1 Global Rules (apply to all categorical columns)***

    Trim leading/trailing whitespace

    Remove hidden/non-printable characters

    Convert to lowercase for uniform processing

    Standardize spacing and punctuation

    Maintain a simple mapping table for any value changes

***6.2 Field-Specific Notes***

status / courier_status / fulfilment

    Normalize inconsistent labels (spelling, casing, synonyms).

    Group similar values into simplified, meaningful categories.

    Keep nulls as null (no imputation).

category / size

    Standardize casing.

    Remove formatting inconsistencies.

    Preserve differences where product distinctions matter.

sales_channel

    Standardize variations (e.g., spacing, casing).

    Map vendor-specific labels into high-level groups.

promotion_ids

    Clean formatting (trim, remove extra commas/spaces).

    Keep raw value; detailed parsing happens in derived fields.

***6.3 Output Requirements***

    All categorical fields use consistent formatting.

    Final categories are clean, readable, and free of duplicates caused by formatting issues.

    Mapping tables (simple CSVs) document every change for transparency.



**7. Numeric Cleaning Rules**

Numeric fields will be cleaned and standardized to ensure they can support reliable calculations, aggregations, and modelling.

***7.1 Global Rules***

    Remove non-numeric characters (commas, symbols, stray text).

    Trim whitespace before conversion.

    Convert cleaned values to proper numeric dtype (int or float).

    Use NaN for invalid or unconvertible values — no assumptions.

    Preserve original missingness (no auto-filling zeros).

***7.2 Field-Specific Notes (Generalized)***

amount / ship charges / price-like fields

    Remove formatting characters.

    Convert to float.

    Retain zero values but flag them for review if needed.

quantity fields

    Ensure values are integers.

    Validate that quantities are non-negative.

currency or numeric-coded fields

    Convert only if values are truly numeric; otherwise treat as categorical.

***7.3 Outlier Handling***

    Identify extremely large or unrealistic numeric values.

    Do not remove automatically — review case-by-case.

    Document any dropped outliers explicitly.

***7.4 Output Requirements***

    All numeric fields are valid numerics (no object dtype).

    No silent coercions — every coercion produces a NaN.

    No leftover symbols, commas, or string artifacts.

    Numeric distributions look realistic for e-commerce datasets.




**8. Text Cleaning Rules**    
Text fields require consistent formatting to ensure accurate grouping, matching, and downstream processing. 
All string-based fields will follow a unified cleaning approach.

***8.1 Global Rules***

    Trim leading and trailing whitespace.

    Remove non-printable or hidden characters.

    Convert text to lowercase for uniform processing (unless case carries meaning, e.g., sizes).

    Standardize spacing (collapse multiple spaces into one).

    Replace obviously broken characters or encoding issues.

***8.2 Field-Specific Notes (Generalized)***

Names / Labels / Status-like fields

    Normalize spelling and remove irrelevant punctuation.

    Ensure final labels are simple, readable, and consistent.

Location fields (city, state, country)

    Trim and standardize formatting.

    Preserve valid text patterns (e.g., bilingual city names, state abbreviations).

Multi-value fields (e.g., promotion_ids)

    Remove trailing commas/spaces.

    Standardize the delimiter (single comma).

    Leave multi-value parsing to derived-column steps.

***8.3 Output Requirements***

    All text fields are clean, readable, and consistently formatted.

    No trailing/leading spaces or hidden characters remain.

    No inconsistent casing or irregular spacing.

    Text values are ready for category mapping, grouping, and analysis.



**9. Derived Columns to Create**

Additional fields will be created to support analysis, segmentation, and modelling. 
These fields do not introduce assumptions; they are derived strictly from the existing dataset.

***9.1 Binary Flags***

    return_flag — 1 if the row indicates a returned item, else 0.

    cancel_flag — 1 if the row indicates a cancelled item, else 0.

    promo_flag — 1 if promotion_ids is present/non-null, else 0.

***9.2 Promotion-Related***

    promo_count — number of promotions applied (based on cleaned promotion_ids).

    promotion_ids_clean — cleaned, standardized version (trimmed, standardized delimiter).

***9.3 Category & Fulfilment Enhancements***

    fulfilment_normalized — cleaned + standardized fulfilment label.

    courier_status_normalized — simplified courier status grouping.

    category_clean — standardized product category.

    city_clean / state_clean — trimmed and standardized location fields.

***9.4 Notes & Exclusions***

    No profit, cost, or margin fields will be created (no assumptions introduced).

    No delay_days field will be created unless additional timestamp columns become available.

***9.5 Output Requirements***

    Derived columns must be fully reproducible from the raw dataset.

    All derived fields should be documented in code and clearly named.

    No business assumptions should be introduced during derivation.



**10. Final Output Schema (Concise & Generalized)**

This section defines the structure of the final cleaned dataset that will be produced at the end of the cleaning process. 
It specifies the columns that will remain, the standardized naming conventions, and all derived fields that will be included.

***10.1 Core Fields (Cleaned & Renamed)***

These fields will remain in the final dataset after renaming and cleaning:

    order_id
    order_date
    sku
    asin
    category_clean
    quantity
    amount
    currency
    fulfilment_normalized
    courier_status_normalized
    sales_channel
    ship_city_clean
    ship_state_clean
    ship_postal_code
    ship_country

***10.2 Derived Fields (Final)***

These fields will be added during transformation:

    return_flag
    cancel_flag
    promo_flag
    promo_count
    promotion_ids_clean
    city_clean / state_clean
    fulfilment_normalized
    courier_status_normalized
    

***10.3 Dropped Columns***

As defined in Section 2:

    Unnamed: 22
    fulfilled-by
    Any intermediate helper fields created during cleaning.

***10.4 Schema Requirements***

The final cleaned dataset must satisfy:

    All column names in snake_case.

    No hyphens, spaces, or mixed-case labels.

    No object dtype for numeric or date fields.

    All categorical fields follow consistent formatting standards.

    No trailing/leading whitespace in any field.

    Missing values represented consistently (NaN or NaT).

    No unnecessary or redundant columns.

***10.5 Output File***

The final cleaned dataset will be saved as:

    clean_master.csv