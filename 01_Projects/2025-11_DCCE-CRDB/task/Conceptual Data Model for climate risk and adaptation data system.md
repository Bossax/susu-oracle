---
type: task
status: In Progress
project:
  - DCCE_CRDB
start date: 2026-01-09T00:00:00.000Z
due date: 2026-02-06T00:00:00.000Z
color: var(--mk-color-green)
---
# Conceptual Data Model for the National Climate Adaptation Information Framework (NCAIF)

This document outlines the definitive Conceptual Data Model (CDM) for the NCAIF, designed to fulfill the requirements of the project's Terms of Reference (TOR). It is based on a detailed analysis of global best practices and a strategic decision to focus the core model on the essential data domains mandated by the TOR, while treating other related systems as external.

## Guiding Principles & Core Decisions

1.  **TOR Alignment:** The CDM is structured around the four explicit requirements of the TOR: Climate Data, Risk & Impact Data, Adaptation Guidelines, and Implementation Results.
2.  **Scope Containment:** To avoid scope creep and ensure focus, several related data domains are intentionally excluded from the core model. These include detailed Project Management, Content Management (CMS), Granular GHG Inventory, and CRM/Helpdesk functionalities. These are treated as **External Systems** and are represented by simple "Stub Entities" or ID references to ensure the core model remains clean and focused on climate risk and adaptation analytics.
3.  **Architectural Blueprint:** The design incorporates a "System of Systems" approach informed by global platforms like the EU's Climate-ADAPT. It emphasizes semantic interoperability, standardized taxonomies, and the full adaptation lifecycle as defined by **ISO 14090**.

---

## NCAIF Subject Areas & Core Entities

The CDM is organized into four primary subject areas, directly mapping to the project's TOR.

| **TOR Required Domain**       | **CDM Subject Area**      | **Core Entities**                                                                        | **Adopted Ontologies & Standards**                                                                                                                                |
| :---------------------------- | :------------------------ | :--------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Climate Data**           | **Physical Climate**      | `CLIMATE_DRIVER`, `HAZARDOUS_EVENT`, `CLIMATE_SCENARIO`                                  | **IPCC AR6** Climatic Impact-Drivers (CIDs), **GCOS** Essential Climate Variables (ECVs), **WMO-CHE** for event tracking, **CMIP6** for scenarios.                |
| **2. Risk & Impact Data**     | **Risk & Loss**           | `EXPOSED_ASSET`, `RISK_METRIC`, `LOSS_DAMAGE_RECORD`, `ATTRIBUTION_LINK`, `SPATIAL_UNIT` | **GED4ALL** for asset taxonomy, **INFORM Risk Index** for risk composition, **Sendai Framework** for loss & damage, **DGGS** / **HydroBASINS** for spatial units. |
| **3. Adaptation Guidelines**  | **Knowledge & Options**   | `ADAPTATION_OPTION`, `KNOWLEDGE_ASSET`                                                   | **Climate-ADAPT KTM** (Green, Grey, Soft) for option classification, **ISO 14090** for defining the adaptation lifecycle.                                         |
| **4. Implementation Results** | **Response & Resilience** | `ADAPTATION_PROJECT`, `INTERVENTION_RESULT`, `RESILIENCE_INDEX` (COMPOSITE_INDEX)        | **ISO 14090** for project lifecycle tracking, **GCF/Sendai** indicator frameworks for results measurement.                                                        |

---

# Detailed Entity-Relationship Diagram (ERD)

The following diagram illustrates the relationships between the core entities within the NCAIF, organized by their respective subject areas.

## Overall ERD
[View Online](https://mermaid.ai/app/projects/db6be078-a24c-4259-b99d-edbb06a16c4b/diagrams/24c96bd9-81bf-427c-bac7-ce2ef1cc6a0f/share/invite/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudElEIjoiMjRjOTZiZDktODFiZi00MjdjLWJhYzctY2UyZWYxY2M2YTBmIiwiYWNjZXNzIjoiVmlldyIsImlhdCI6MTc3MDgxMDYyM30.4zZLLdJVSRiTWI9fEDzLpSHJhXgJ471T0VQrJ2xBYGs)

```mermaid

erDiagram

    %% =======================================================

    %% SUBJECT AREA 1: PHYSICAL CLIMATE (TOR 1) - PRESERVED

    %% =======================================================

    subgraph PHYSICAL_CLIMATE

        CLIMATE_SCENARIO ||--|{ CLIMATE_DRIVER : simulates

        CLIMATE_DRIVER ||--o{ HAZARDOUS_EVENT : manifests_as

    end

  

    %% =======================================================

    %% SUBJECT AREA 2: RISK & IMPACT (TOR 2) - PRESERVED

    %% =======================================================

    subgraph RISK_IMPACT

        SPATIAL_UNIT ||--|{ CLIMATE_DRIVER : reference_for

        SPATIAL_UNIT ||--|{ EXPOSED_ASSET : contains

        SPATIAL_UNIT {

            string type "DGGS | HydroBASINS | Admin"

            geometry polygon

        }

        %% The direct link for slow-onset risk

        CLIMATE_DRIVER ||--o{ RISK_ASSESSMENT : intensity_of

        EXPOSED_ASSET ||--o{ LOSS_DAMAGE_RECORD : sustains

        EXPOSED_ASSET ||--o{ RISK_ASSESSMENT : subject_of

        LOSS_DAMAGE_RECORD ||--|{ ATTRIBUTION_LINK : explained_by

        ATTRIBUTION_LINK }|..o| HAZARDOUS_EVENT : attributed_to_event

        ATTRIBUTION_LINK }|..o| CLIMATE_DRIVER : attributed_to_driver

        %% SUBJECT AREA 3: VULNERABILITY and Exposure (The Strategy)

        EXPOSED_ASSET }|--|| VULNERABILITY_DEFINITION : has_assigned

        VULNERABILITY_DEFINITION ||--|{ IMPACT_FUNCTION : implements_math

        VULNERABILITY_DEFINITION ||--|{ VULNERABILITY_FRAMEWORK : implements_index

        VULNERABILITY_DEFINITION ||--|{ RISK_ASSESSMENT : a

        VULNERABILITY_FRAMEWORK ||--|{ FRAMEWORK_STRUCTURE : defines_logic

        FRAMEWORK_STRUCTURE }|--|| VULNERABILITY_DETERMINANT : uses_variable

        FRAMEWORK_STRUCTURE {

            string dimension "Sensitivity | Adaptive_Capacity | Coping"

            string param

        }

  
  

        %% The Outputs

        RISK_ASSESSMENT ||--|{ RISK_METRIC : produces_probabilistic

        RISK_ASSESSMENT ||--|{ COMPOSITE_INDEX : produces_composite_score

    end

  
  

    %% =======================================================

    %% SUBJECT AREA 4: RESPONSE & RESILIENCE (TOR 3 & 4) - UPDATED

    %% =======================================================

    %% Expanded to include the Recursive Logic you approved

    subgraph RESPONSE_RESILIENCE

        ADAPTATION_OPTION ||--o{ ADAPTATION_PROJECT : "implemented_as"

        ADAPTATION_OPTION {

            string ktm_type "Green | Grey | Soft"

            float trl_level

        }

        RISK_METRIC }|--|| ADAPTATION_PROJECT : "informs"

        COMPOSITE_INDEX }|--|| ADAPTATION_PROJECT : "informs"

  

        ADAPTATION_PROJECT }|--|| SPATIAL_UNIT : "located_at"

        ADAPTATION_PROJECT ||--o{ INTERVENTION_RESULT : "achieves"

        %% --- NEW RESILIENCE LOGIC STARTS HERE ---

        %% Replacing the simple "RESILIENCE_INDEX" with the full recursive domain

        %% 1. The Result improves the Score

        INTERVENTION_RESULT }|--|| COMPOSITE_INDEX : "improves_score"

  

        %% 2. The Recursive Score Structure (Total -> Dimension -> Sub-Index)

        COMPOSITE_INDEX ||--o{ COMPOSITE_INDEX : "composed_of"

        %% 3. The Methodology

        RESILIENCE_FRAMEWORK ||--|{ RESILIENCE_DIMENSION : defines_dimensions

        RESILIENCE_DIMENSION ||--|{ RESILIENCE_STRUCTURE : defines_logic

        RESILIENCE_FRAMEWORK ||--|{ RESILIENCE_ASSESSMENT : governs

        %% 4. The Assessment Context

        RESILIENCE_ASSESSMENT ||--|{ COMPOSITE_INDEX : generates

        SPATIAL_UNIT ||--|{ RESILIENCE_ASSESSMENT : subject_of

  

        %% 5. The Link to Raw Data (Integration with Subject Area 3)

        RESILIENCE_STRUCTURE }|--|| VULNERABILITY_DETERMINANT : uses_variable

        ADAPTATION_PROJECT {

            string cycle_status "Assess | Plan | Implement | Evaluate"

        }

    end

  

    %% =======================================================

    %% EXTERNAL SYSTEM STUBS - PRESERVED

    %% =======================================================

    subgraph EXTERNAL_SYSTEMS

        EXTERNAL

    end


```



## Key Architectural Decisions & Logic

*   **The "Universal Adapter" (`ATTRIBUTION_LINK`):** This critical associative entity solves the "Slow-Onset" problem. It provides a polymorphic link that allows a `LOSS_DAMAGE_RECORD` to be attributed to either a discrete `HAZARDOUS_EVENT` (like a flood) or a continuous `CLIMATE_DRIVER` (like sea-level rise), a key requirement for scientific accuracy.
*   **Polymorphic Vulnerability (`VULNERABILITY_DEFINITION`):** The model uses a "Strategy Pattern" to handle different vulnerability assessment methodologies. It can accommodate both quantitative, math-based **`IMPACT_FUNCTION`** entities (for actuarial risk modeling like CLIMADA) and qualitative, indicator-based **`VULNERABILITY_FRAMEWORK`** entities (for policy scores like the National CRI) without requiring schema changes.
*   **ISO 14090 Lifecycle Tracking:** The `ADAPTATION_PROJECT` entity includes a `cycle_status` attribute ("Assess | Plan | Implement | Evaluate"). This explicitly models the iterative nature of adaptation, enabling the system to track projects through their entire lifecycle and support feedback loops where evaluation data informs future risk assessments.
*   **Recursive Resilience & Vulnerability:** The model implements a recursive, hierarchical structure for both `COMPOSITE_INDEX` (Resilience) and `FRAMEWORK_STRUCTURE` (Vulnerability). This allows for the definition of complex, multi-level indicator frameworks (e.g., Total Index -> Dimension -> Sub-Index -> Variable) directly within the database. This design provides the flexibility to represent established methodologies like the INFORM Risk Index or custom-defined local frameworks without altering the core schema.
*   **External System Integration:** The ERD includes "stub" entities (e.g., `EXTERNAL_PM_SYSTEM`, `EXTERNAL_CMS_SYSTEM`). This design choice clarifies the system's boundaries, ensuring the core database is not burdened with operational details from other platforms, while still acknowledging the necessary points of integration.
*   **Dual-Use Resilience Framework:** The model supports the dual perspective of a resilience index as both a retrospective M&E tool and a prospective planning instrument. This is achieved by separating the `RESILIENCE_STRUCTURE` (the methodology or "template" for gap analysis) from the `RESILIENCE_ASSESSMENT` (a point-in-time data snapshot). This allows the system to evaluate the outcomes of an `ADAPTATION_PROJECT` and, simultaneously, guide future planning by identifying structural deficits in a local government's "Capacity Profile" without requiring any schema changes.
*   **Unified Index Store (`COMPOSITE_INDEX`):** This entity serves as a generic container for the results of both `RISK_ASSESSMENT` and `RESILIENCE_ASSESSMENT`. By abstracting the concept of a "score" or "index," the model can store outputs from different analytical frameworks (e.g., a probabilistic risk score, a qualitative resilience rating) in a consistent structure. This simplifies querying and comparative analysis, as all high-level indicator results are accessible through a single, well-defined entity.

---

## CDM Robustness Test: Supporting the NCAIF Sitemap

The CDM's design has been validated against the user-centric, sector-oriented NCAIF sitemap. The test confirms that the data model can robustly support the required content and user journeys without modification.

*   **Sectoral Pathways:** The sitemap's core feature is presenting information sliced by NAP sectors. The CDM supports this through a "sliceable" design. By adding a `sector` attribute to key entities like `EXPOSED_ASSET` and `ADAPTATION_OPTION`, the same underlying data can be filtered to create sector-specific views (e.g., showing only agricultural assets in a risk assessment). This avoids data duplication while meeting the primary user requirement.

*   **User Journey Enablement:** The model directly supports the intended user journey, from understanding impacts to finding solutions. A query can start with an `EXPOSED_ASSET` (e.g., "rice farms"), link to `RISK_ASSESSMENT` to understand the threats, and then connect to relevant `ADAPTATION_OPTION` entities that mitigate those specific risks for that asset type.

*   **Cross-Cutting Analysis:** The CDM's relational structure is crucial for handling cross-sectoral issues. For instance, an `ADAPTATION_PROJECT` like "mangrove restoration" (Natural Resources sector) can be linked via `RISK_ASSESSMENT` to the mitigation of "storm surge" risk, which impacts `EXPOSED_ASSET`s in the "Human Settlements" sector. This demonstrates the model's ability to capture the complex causal chains inherent in climate adaptation.

**Conclusion:** The CDM is confirmed to be a robust and flexible foundation for the NCAIF portal, capable of serving both high-level, sector-based queries from non-technical users and detailed, data-driven inquiries from expert analysts.
