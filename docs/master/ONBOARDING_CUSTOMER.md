# ONBOARDING_CUSTOMER.md — Customer Onboarding Runbook (SSOT)

**Scope:** Dieses Dokument ist das wiederverwendbare Runbook für das Onboarding **jedes** Kunden in Flowsight.  
**SSOT:** Repo C:\flowsight-base (dieses Dokument ist SSOT).  
**Arbeitsmodus:** ZIP-first, contract-first, deterministisch, ohne UI-Guessing.  
**No-Drift:** Keine Inline-Styles in Webflow, keine manuellen CSS-Overrides, kein CSS außerhalb des einen aktiven Theme-Blocks.

---

## 0) Preflight — Workstream & SSOT-Constraints (Stage 0)

### Ziel
Klarer Workstream + eindeutige SSOT-Regeln + keine Drift-Grundlagen.

### Inputs (vom Kunden / intern)
- Kundenname (Brand)
- Region Label (z.B. Kanton Zürich)
- Ziel: neue Website / Relaunch / Scope
- Verantwortliche Person (intern) + Ansprechpartner beim Kunden (Name/Role)

### Aktionen (intern)
- Entscheide Customer-Slug (stabil, nicht ändern)
- Lege Customer-Ordner an (scaffold aus 	emplate-on pattern)
- Entscheide **Asset-Quelle pro Kunde** (eine Quelle, kein Mix)

### Gates / Definition of Done
- [ ] Customer-Slug fix (Format: -z0-9-, stabil, keine Umlaute)
- [ ] Customer scaffold existiert: customers/<slug>/customer.json
- [ ] Asset-Quelle fixiert (eine Domain / ein CDN)
- [ ] Workstream dokumentiert (z.B. golden-ch als Benchmark)

### Artefakte / Outputs
- customers/<slug>/customer.json (scaffold)
- Notiz: sset_source = <domain>

### Links
- Repo Workflow/Struktur: docs/master/01_REPO_STRUCTURE_AND_WORKFLOW.md
- Data Model/Slots: docs/master/02_DATA_MODEL_AND_SLOTS.md
- Webflow Blueprint: docs/master/03_WEBFLOW_PHASE1_BLUEPRINT.md

---

## 1) Identity & Brand (Stage 1)

### Ziel
Brand/Identity so definieren, dass Hero + Header + Footer deterministisch befüllbar sind.

### Inputs (vom Kunden)
- Brandname + ggf. Legal Name
- Logo (URL, Asset-Quelle beachten)
- 1 Satz Positionierung (Differenzierung)
- Primary CTA (Text + Ziel)
- Secondary CTA (Text + Ziel)
- Notfall/24h: ja/nein + Zeiten

### Aktionen (intern)
- Befülle usiness.* + rand.* (nur Werte, Keys unverändert)
- Befülle Hero (Headline/Subline) + CTAs nach Contract

### Gates / Definition of Done
- [ ] Brand/Logo URL ist gültig (HTTP 200, lädt)
- [ ] Primary/Secondary CTA klar (keine Platzhaltertexte)
- [ ] Hero ist spezifisch (kein generisches “Willkommen”)

### Artefakte / Outputs
- customer.json: usiness, rand, hero (contract-konform)

### Links
- Customer JSON Template Doku: docs/master/07_CUSTOMER_JSON_TEMPLATE.md

---

## 2) Asset/Media Policy (Stage 2) — Hard Rule, Anti-Chaos

### Ziel
Zero Chaos bei Medien: pro Kunde exakt **eine** Quelle.

### Non-Negotiables
- **Genau 1 Quelle pro Kunde**:
  - Option A (default bis assetBase existiert): **CDN-only**, absolute URLs
  - Option B (später): definierter Asset-Ordner + zentraler ssetBase Mechanismus
- **Kein Mix**: nicht mehrere Domains/Hosts innerhalb eines Kunden

### Inputs (vom Kunden)
- Wo liegen Logo/Bilder? (CDN/Drive/Dropbox/Website)
- Rechte/Einwilligung für Bilder/Reviews

### Aktionen (intern)
- Entscheide sset_source (Domain)
- Normalisiere alle Medien-URLs auf diese Quelle

### Gates / Definition of Done
- [ ] Alle Medien-URLs eines Kunden teilen dieselbe Quelle/Domain
- [ ] Keine relativen Pfade (bis assetBase existiert)
- [ ] Keine Platzhalterbilder

---

## 3) Proof-First Data: Cases + Photos + Reviews (Stage 3) — High Impact

### Ziel
High-End Messbarkeit: Template wirkt nicht “leer”, UI/Theme-Entscheidungen werden valide.

### Golden-Minimums (Gate, verpflichtend)
- min **6** Cases
- min **12** Case-Images total
- min **8** Reviews

---

## 4) Offer Model: Services / Process / Areas (Stage 4)
(… wird stage-weise geschärft …)

## 5) Trust Layer: Partner / Certs / Badges (Stage 5)
(… wird stage-weise geschärft …)

## 6) Contact & Compliance (Stage 6)
(… wird stage-weise geschärft …)

## 7) Webflow Structure Binding (Stage 7)
(… wird stage-weise geschärft …)

## 8) Gates & Release (Stage 8)
- 	ools/handoff/22_full_gates.ps1
- Commit + Push → SHA verifizieren

## 9) Smoke Test (Stage 9)
(… wird stage-weise geschärft …)

---

# Appendix A — Customer Intake Snapshot (pro Kunde ausfüllen)
- Customer Slug:
- Brandname:
- Region Label:
- Asset Source (ONE):
- Primary CTA:
- Secondary CTA:
- Notfall/24h:
- Top 3 Services:
- Areas (15–25):
- Cases (6–8) + Image URLs:
- Reviews (8–12) + Quelle:
- Partner/Certs (8–12):
- Contact (Addr/Phones/Hours/Map):