#!/bin/bash

# =============================
# CONFIGURATION
# =============================
REPO="Mehr-Noor/mychat"        # تغییر بده به OWNER/REPO خودت
ASSIGNEE="Mehr-Noor"           # تغییر بده به GitHub username خودت

# =============================
# LABELS (تمامی labels مورد نیاز)
# =============================
labels=("epic" "task" "backend" "ai" "priority-critical")

echo "Checking and creating Labels..."
for label in "${labels[@]}"; do
    if ! gh label list --repo "$REPO" | grep -qw "$label"; then
        echo "Creating label: $label"
        gh label create "$label" --repo "$REPO" --color "ffffff" --description "$label label"
    fi
done

# =============================
# EPICS
# =============================
declare -A epics
epics["EPIC 1"]="Environment Setup|Setup WSL2, Python environment, CUDA, dependencies, and folder structure."
epics["EPIC 2"]="LLM Engine Layer|Tasks related to model loading, streaming, inference logic, and GPU memory."
epics["EPIC 3"]="Database & Session Management|Design DB schema, session CRUD, message CRUD, tests."
epics["EPIC 4"]="FastAPI Backend|Endpoints, streaming, CORS, error handling, logging."
epics["EPIC 5"]="React Frontend|UI components, multi-session support, streaming, sidebar."
epics["EPIC 6"]="Context & Memory Management|Recent messages, context building, summarization."
epics["EPIC 7"]="Security Hardening|Offline only, DB encryption, CORS, rate limiter."
epics["EPIC 8"]="Dockerization|Containerization, GPU support, volume mounting."

declare -A epic_ids

echo "Creating Epics..."
for key in "${!epics[@]}"; do
  title="[$key] ${epics[$key]%%|*}"
  body="${epics[$key]#*|}"
  
  # ایجاد Epic
  issue_number=$(gh issue create \
    --title "$title" \
    --body "## Description\n$body" \
    --label "epic,backend,ai,priority-critical" \
    --assignee "$ASSIGNEE" \
    --repo "$REPO" \
    --json number | jq -r '.number')
  
  epic_ids["$key"]=$issue_number
  echo "Created Epic: $title #$issue_number"
done

# =============================
# TASKS (Phase 1)
# =============================
declare -A tasks
tasks["Install WSL2"]="## Description
Install WSL2 and Ubuntu on Windows.

## Acceptance Criteria
- Ubuntu terminal works
- Can run bash commands
Epic: EPIC 1"
tasks["Install Python & venv"]="## Description
Install Python 3.11 and create virtual environment.

## Acceptance Criteria
- Python 3.11 installed
- venv works
Epic: EPIC 1"
tasks["Install CUDA & Drivers"]="## Description
Install NVIDIA CUDA toolkit and drivers for GPU.

## Acceptance Criteria
- nvidia-smi shows GPU
- PyTorch CUDA available
Epic: EPIC 1"
tasks["Install Python Packages"]="## Description
Install PyTorch, Transformers, bitsandbytes, accelerate.

## Acceptance Criteria
- Imports work
- torch.cuda.is_available() == True
Epic: EPIC 1"
tasks["Download & Test Mistral 7B"]="## Description
Download Mistral 7B Instruct 4bit and run test script.

## Acceptance Criteria
- Model loads on GPU
- Generates output
Epic: EPIC 2"
tasks["Create llm_engine module"]="## Description
Implement model loading and generate() function.

## Acceptance Criteria
- Streaming generation works
- Configurable temperature & max_tokens
Epic: EPIC 2"
tasks["Create SQLAlchemy models"]="## Description
Create ChatSession and Message tables.

## Acceptance Criteria
- Tables created
- CRUD works
Epic: EPIC 3"
tasks["Create FastAPI endpoints"]="## Description
Endpoints: create-session, list-sessions, chat, delete-session.

## Acceptance Criteria
- Each endpoint tested
- Streaming response works
Epic: EPIC 4"
tasks["Setup React Frontend"]="## Description
Initialize Vite project and create basic UI.

## Acceptance Criteria
- Frontend starts
- Can send requests to backend
Epic: EPIC 5"

echo "Creating Tasks..."
for key in "${!tasks[@]}"; do
  title="[Task] $key"
  body="${tasks[$key]}"
  
  # استخراج Epic برای لینک
  epic_key=$(echo "$body" | grep "Epic:" | awk -F': ' '{print $2}')
  epic_number=${epic_ids[$epic_key]}
  
  # اضافه کردن Epic لینک
  body=$(echo "$body" | sed "/Epic:/d")   # حذف خط Epic از متن
  body="$body

Related Epic: #$epic_number"
  
  gh issue create \
    --title "$title" \
    --body "$body" \
    --label "task,backend,ai,priority-critical" \
    --assignee "$ASSIGNEE" \
    --repo "$REPO"
    
  echo "Created Task: $title linked to Epic #$epic_number"
done

echo "All Epics and Tasks have been created successfully!"