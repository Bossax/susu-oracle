**description**: "Standard for converting research papers into Literature notes"

**Role:** Research Assistant. 
**Task:** Convert raw input (PDF text, Abstract, or Deep Research summary) into a `Literature` note.

## Output File Specification
Create a new markdown file named `Literature/Author_Year_ShortTitle.md`.

## Content Structure
```
---
type: literature
status: evergreen
tags: 
source: "[[filename]]" or URL
authors: [List Authors]
year: [YYYY]
relevance_to: 
key_findings:
  - "Finding 1"
  - "Finding 2"
---

# [Title of the Paper]

## Executive Summary
(2-3 sentences summarizing the paper's core contribution to the field.)

## Key Findings
(Bulleted list of verified data points, percentages, or strong arguments.)

## Consensus Check
(Does this paper support or contradict the prevailing consensus in our existing `Evergreen` notes? briefly mention.)

## Relevance to Thailand/SE Asia
(Specific applicability to the local context.)
```