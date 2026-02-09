---
type: strategy
status:
  - current
version: 4
created: 2025-12-12
last_updated: 2026-01-14
project:
  - DCCE_CRDB
---
# 1. Current project health & priority

The project status is **Green (On Track)** following the strategic reframing to an "IVRA-First" architecture. The priority is shifting from planning to **validation**, specifically preparing for **FGD 1 (Late Jan)**. The core focus is now to position the project not as building "just another platform," but as designing the **Risk Assessment Data System** that will ingest and integrates data from the fragmented data product landscapes.

# 2. Near‑term focus (next 2–4 weeks)

1. **FGD 1 Execution (Late Jan):** Facilitate the session with GHG & M&E project owners to validate the "Data Exchange" model rather than just auditing their IT.
    
2. **Integration Proof-of-Concept:** Define the preliminary **Canonical Data Model** required to ingest M&E datasets into our Risk platform (the "Pipeline" approach). <!--note: highly uncertain-->
    
3. **Use Case Finalization:** Lock down 3–5 "Seed Use Cases" (e.g., Flood, Drought) to demonstrate the necessity of the conceptual data model during the progress meeting.
    
4. **IVRA Knowledge Synthesis:** Complete the planning of the review of the _Climate Change Risk and Impact (IVRA)_ study to inform the BTR Adaptation Chapter (WP5).
    
5. **ADPC Coordination:** Prepare the metadata template and observation strategy for the **Feb 11** ADPC consultation to maximize metadata intelligence gathering.
    

**3. Key decisions & assumptions to remember**

- **Scope Reframing:** The "Data System" is strictly defined as the **Risk Assessment (IVRA) System**; it serves as the central hub, with M&E and GHG treated as external sources.
    
- **Integration Strategy:** We will demonstrate integration by creating a **Data Pipeline** (API/Batch) to ingest M&E, rather than trying to unify all databases. <!--note: highly uncertain-->
    
- **Existing Landscape:** We assume the current DCCE website is a "shelf of fragmented products"; our system will be the structured "backend" (Lakehouse) that future visuals rely on.
    
- **M&E Relationship:** We accept the CU M&E framework "as-is" (despite flaws) and focus on creating an interface to consume their "Stage 5 Results" data.
    
- **Catalog Approach:** The Data Catalog will be implemented as a **structured spreadsheet** (Low-code) to ensure practicality and ease of handover, not a complex software tool.
    

**4. Imminent milestones & deadlines**

- **22-Jan 2026:** Focus Group #1 (Internal Ecosystem Mapping).
    
- **11 Feb 2026:** ADPC Consultation Workshop (Supply-side validation).
    
- **Early Mar 2026:** Focus Group #2 (Prototype Pre-Validation).
    
- **27 Mar 2026:** **Interim Report Submission** (Critical for Billing/Payment).
    
- **07 Apr 2026:** Formal Interim Report Deadline (TOR).
    

**5. Short‑term risks & watchpoints**

- **Technical Feasibility:** Can we actually get an API or automated feed from the M&E/GHG systems, or will we be forced into manual CSV uploads?
- **Stakeholder Buy-in:** Risk that M&E/GHG teams perceive the "Ingestion Pipeline" as an audit or oversight mechanism rather than suport.
    
- **Scope Creep:** Ensure the "Loss & Damage" model stays within the logical design and doesn't expand into building a full operational disaster response system.
    

**6. Next sponsor/steering message**

- **Strategy Shift:** We have reframed the scope to prioritize the **Risk Assessment (IVRA)** domain, ensuring we deliver a working engine before expanding to other areas.
    
- **Integration:** We are designing a "Data Pipeline" to automatically ingest data from the M&E and GHG projects, turning fragmented systems into a unified insight flow.
    
- **Upcoming Action:** In **FGD 1 (Late Jan)**, we will validate this "Exchange Model" with the project owners to ensure technical feasibility.
    
- **Goal:** This approach ensures your future budget requests cover a robust **Data Lakehouse**, not just another isolated dashboard on the website.