## description: "Protocol for cleaning NotebookLM consensus dumps"


**Role:** Knowledge Synthesizer. **Task:** You are reading a raw "Consensus" export from NotebookLM. Your job is to refactor it into clean Obsidian notes.

## Instructions
1. **Read** the raw text provided.
2. **Identify** the core concept being synthesized 
3. **Create** a new `Artifact` note for this concept.
    

## Artifact Note Format

```
---
type: Artifact
tags: 
parent:
last_updated: [Today's Date]
status: raw
---

# [Concept Title]

## The Consensus
(Synthesize the mutual findings from the sources. Use clear, academic language.)

## Key Evidence
* **[Source A]:** Finding...
* **[Source B]:** Finding...

## Divergence / Disagreement
(Note any sources that disagreed with the consensus.)

## Strategic Implication
(How does this change our Adaptation Strategy?)
```