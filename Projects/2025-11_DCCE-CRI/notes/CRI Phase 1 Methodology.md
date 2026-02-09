---
type:
  - Artifact
status: current
last_updated: 2026-02-03
version: 2
project:
  - DCCE_CRI
related_hypothesis:
color: var(--mk-color-purple)
---
>[!note] Change Log
>- v1: approach summary with decision points
>- v2: pivot project direction

>[!Document]
>1. [[Sectoral Adaptation Guideline Study and CRI pilot study]]
>2. [DCCE_CRI2_AW_ข้อเสนอแนะเชิงนโยบายการพัฒนา CRI_rev 20-12-68.pdf](https://thecreagycom.sharepoint.com/:b:/s/DCCECRI2/IQCsgkODJZdTR5XysjDDHSQMAQMzFp6JEJQQZPVQdAlUhDI?e=OabjFa)
>3. [CRI1-TEI_Data_59_66 cal.xlsx](https://thecreagycom.sharepoint.com/:x:/s/DCCECRI2/IQBmI_yahsxBQ5m8uAiRRJ-CAS7jDzkpqunCw3cPJO_nBZs?e=YvrgJY)
>4. https://thecreagycom.sharepoint.com/:b:/s/DCCECRI2/IQDWyMlbYZdMQbaqD63d_9f7AeROxjHmUKUiNPA8QTvUuys?e=BUzRVR
>



# 1. Summary 

This document outlines the refined methodology for the Thailand Climate Risk Index (CRI). Building upon the Pilot Phase (2023), this framework addresses critical limitations regarding spatial resolution and data consistency.

**Core Strategic Shifts:**

1. **From "Total Damage" to "Fiscal Relief":** The economic component is explicitly redefined as a **Fiscal Relief Index**. It measures the burden on government emergency budgets (Relief Payments), rather than total physical economic loss. This aligns with available data reality. <!--todo: to be discussed-->
    
2. **"Constrained Redistribution" Approach:** To resolve the conflict between official administrative data and high-resolution global data, we apply a "Constrained Redistribution" method. Global datasets are used strictly to _spatially disaggregate_ official provincial/district totals, ensuring the final numbers match Ministry of Interior (DOPA) records exactly.
    
3. **Gap-Aware Calculation:** "Zero" values in the dataset are no longer automatically treated as "Low Risk." They are cross-referenced with hazard exposure layers to flag "Administrative Data Gaps."
    

## 2. The Equation Framework (Composite Index)

The CRI Score ($0-100$) is a composite of **Human Impact** and **Economic Impact**.

### 2.1 Weighting Structure

We retain the Germanwatch principle of equal weighting between Human and Economic dimensions but refine the sub-indicators to eliminate redundancy. <!--todo: to be discussed-->

|Dimension|Indicator|Weight|Rationale|
|---|---|---|---|
|**A. Human Impact**|**Fatalities & Affected (Relative)**|**50%**|Prioritizes impact per capita to ensure populous provinces don't skew the index simply due to size.|
|**B. Economic Impact**|**Fiscal Relief per Sector GPP**|**50%**|Measures the _intensity_ of government financial strain relative to the size of the specific economic sector (Agriculture).|

### 2.2 Refined Formulas ⚠️ to be discussed

#### A. Human Impact (Population Weighted)

Unlike the Pilot, which summed Absolute and Relative values (double counting), we prioritize **Relative Impact** for the index score, while retaining Absolute numbers for "Magnitude" visualization only.

$$Score_{Human} = \frac{Fatalities}{Population_{District}} \times W_1 + \frac{Affected}{Population_{District}} \times W_2$$

#### B. Economic Impact (Sector-Specific Normalization)

_Correction from Pilot:_ We strictly divide Agricultural Relief by **Agricultural GPP**, not Total GPP. Dividing agricultural loss by Total GPP (which includes factories/services) falsely minimizes risk in industrialized provinces.

$$Score_{Economic} = \frac{Ag\_Relief\_Payment}{Ag\_GPP_{Prov}}$$

> **Note on Urban/Industrial Risk:** Since relief payments for factories are rare/non-existent in this dataset, Urban Economic Risk is calculated via a separate **Exposure Proxy** (Commercial Land Use) rather than historical loss data.

## 3. Data Architecture: The "Hybrid" Model

We utilize a **Hybrid Data Model**. "Official Data" provides the _Magnitude_ (How much?), while "Global Data" provides the _Location_ (Where?).

### 3.1 Dataset Catalog

|Component|Role|Dataset Name|Source / Provider|Resolution|
|---|---|---|---|---|
|**Human Magnitude**|**Official Constraint**|**Population Registration (Tabien Baan)**|DOPA (Dept of Provincial Administration)|District (Amphoe)|
|**Human Distribution**|**Spatial Weighting**|**WorldPop Unconstrained Global Mosaic**|University of Southampton / WorldPop|100m Raster|
|**Human Distribution**|_Alternative/Validation_|**GHS-POP (Global Human Settlement)**|JRC (European Commission)|100m Raster|
|**Economic Magnitude**|**Official Constraint**|**Disaster Relief Payments (4 Types)**|Office of Agricultural Economics / DDPM|Provincial|
|**Economic Zoning**|**Value Potential**|**Agri-Map (Zoning by Agri-Map)**|LDD (Land Development Dept)|Vector (Poly)|
|**Economic Extent**|**Physical Mask**|**ESA WorldCover v2021**|European Space Agency|10m Raster|
|**Hazard Validation**|**Gap Flagging**|**GISTDA Flood/Drought Extent**|GISTDA|Raster|

## 4. Technical Implementation: Dasymetric Mapping

To solve the "Coarse Resolution" pain point, we employ Binary Dasymetric Mapping.

### 4.1 Concept: "Constrained Redistribution"

We do not replace DOPA population numbers. We redistribute them.

**The Algorithm:** For a given District $D$ with Official Population $P_{official}$:

1. Extract WorldPop grid cells falling within District $D$.
    
2. Calculate the sum of WorldPop values in that district: $\sum WP_{cells}$.
    
3. Calculate the **Correction Factor (**$CF$**)**:
    
    $$CF = \frac{P_{official}}{\sum WP_{cells}}$$
4. Apply $CF$ to every pixel.
    
    $$Final\_Pop_{pixel} = WP_{pixel} \times CF$$

**Result:** A high-resolution population map where the sum of all pixels **exactly equals** the Ministry of Interior's official number.

### 4.2 Handling "Latent Population" 

In many economic zones (e.g., Rayong), Satellite Population ($WP$) will be significantly higher than Official Registration ($P_{official}$).

- **Action:** We calculate the residual ($WP - P_{official}$) and store it as a separate layer: **"Latent Population Risk Layer."**
    
- **Usage:** This layer is for _emergency response planning_ only, not for the core Fiscal Index (which relies on registered heads-count for budget allocation).
    

## 5. Economic Zoning & Urban Proxies

### 5.1 The Agricultural Filter

To accurately map economic loss, we intersect three layers:
1. **Agri-Map (LDD):** Defines _what_ the crop is (e.g., Rice vs. Rubber). This determines the "Economic Value per Rai."
    
2. **ESA WorldCover (ESA):** Defines _where_ the crop physically is (removing farm roads, houses, and forests from the LDD polygons).
    
3. **Flood/Drought Mask (GISTDA):** Defines _if_ it was hit. <!--todo:  to be decided-->
    

### 5.2 The "Bangkok" Fix

Bangkok and industrial estates often show "Zero Relief" despite high risk, ~~because factories rely on private insurance, not government handouts.~~

- **Proxy Variable:** For non-agricultural zones (Urban/Industrial), risk is defined by **Exposure**, not Historical Relief.
    
- **Data Source:** **Industrial GPP** (NESDC) weighted by **Commercial/Industrial Land Use** (ESA WorldCover class 50/60).
    

## 6. Data Quality & Limitations

### 6.1 The "Gap Flag" Protocol

A major flaw in the Pilot was treating "Missing Data" as "Zero Risk."
- **Protocol:** If `Hazard_Satellite = TRUE` AND `Relief_Official = 0`:
    - **Flag:** "Administrative Gap" (Pink Code).
    - **Action:** Exclude from the "Low Risk" ranking. Display as "Insufficient Data" on the map.
        

### 6.2 Definition of "Loss" ⚠️ to be decided

The CRI calculates **Fiscal Vulnerability**, not Total Economic Loss.
- _Excluded:_ Private insurance claims, unrealized opportunity costs, supply chain disruptions.
- _Included:_ Direct government compensation payments (Kor-Or-Por/Vor-Por) and municipal emergency budget usage.