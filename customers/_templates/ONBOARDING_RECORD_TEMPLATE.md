# ONBOARDING_RECORD â€” <customer_display_name>
Status: DRAFT
Owner: <name>
Created: <yyyy-mm-dd>
Mode: <golden|scaffold|production>

## Stage 0 â€” Intake & Identity
customer_display_name=
customer_slug=
legal_entity_type=
market_country=
market_region_or_city=
primary_language=
mode=

Gate 0: PASS|FAIL
Notes:

---

## Stage 1 â€” Scope Matrix
Ref Inventory: docs/master/MASTER_TEMPLATE_EXPORT_INVENTORY.md

GOLDEN_ALL_ON=(yes|no)
SECOND_LANGUAGE=(no|yes -> which?)
OFF_EXCEPTIONS:
- none

Gate 1: PASS|FAIL
Notes:

---

## Stage 2 â€” Proof Pack (Golden 6/12/8)
IMAGE_MODE=(duplicate-seed|distinct)

CASES_6:
- gc-001: title= | city= | problem= | fix= | result=
- gc-002: title= | city= | problem= | fix= | result=
- gc-003: title= | city= | problem= | fix= | result=
- gc-004: title= | city= | problem= | fix= | result=
- gc-005: title= | city= | problem= | fix= | result=
- gc-006: title= | city= | problem= | fix= | result=

REVIEWS_8_SOURCE=
REVIEWS_8_TEXTS:
1) 
2) 
3) 
4) 
5) 
6) 
7) 
8) 

CERTS_PARTNERS_BADGES=

Gate 2: PASS|FAIL
Notes:

---

## Stage 3 â€” Data Contract Plan
CONTRACT_READY=(yes|no)
STABLE_IDS:
- cases.case_id format=
- reviews.id format=
OPTIONAL_SECTIONS_OFF:
- none

Gate 3: PASS|FAIL
Notes:

---

## Stage 4 â€” Assets Policy (Inbox outside repo)
INBOX_PATH=C:\flowsight-staging\<customer_slug>\inbox\
SEED_OK=(yes|no)
DISTINCT_INPUT=(ready_12|not_ready)

Gate 4: PASS|FAIL
Notes:

---

## Stage 5 â€” Webflow Binding Plan
WEBFLOW_IDS_LOCKED=(yes|no)
SECTION_TOGGLES_CONFIRMED=(yes|no)
ATTR_BINDINGS_PLAN=(ready|tbd)

Gate 5: PASS|FAIL
Notes:

---

## Stage 6 â€” Execution Preconditions
GIT_PORCELAIN=<paste output>   # must be empty
ZIP_IN_ROOT=(yes|no)
INBOX_OK=(yes|no)
GO_EXECUTION=(yes|no)

Gate 6: PASS|FAIL
Notes:

---

## Stage 7 â€” Change Control (only if process changes)
Decision=
Why=
Impact=