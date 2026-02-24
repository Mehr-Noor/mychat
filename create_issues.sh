#!/bin/bash

# تنظیمات
REPO="Mehr-Noor/mychat"  # <-- تغییر بده به نام ریپوی خودت
ASSIGNEE="Mehr-Noor"               # <-- نام کاربری GitHub خودت

# =========================
# EPICS
# =========================

declare -A epics
epics["EPIC 1"]="Environment Setup|Setup WSL2, Python environment, CUDA, dependencies, and folder structure."
epics["EPIC 2"]="LLM Engine Layer|Tasks related to model loading, streaming, inference logic, and GPU memory."
epics["EPIC 3"]="Database & Session Management|Design DB schema, session CRUD, message CRUD, tests."
epics["EPIC 4"]="FastAPI Backend|Endpoints, streaming, CORS, error handling, logging."
epics["EPIC 5"]="React Frontend|UI components, multi-session support, streaming, sidebar."
epics["EPIC 6"]="Context & Memory Management|Recent messages, context building, summarization."
epics["EPIC 7"]="Security Hardening|Offline only, DB encryption, CORS, rate limiter."
epics["EPIC 8"]="Dockerization|Containerization, GPU support, volume mounting."

echo "Creating Epics..."
for key in "${!epics[@]}"; do
  title="[$key] ${epics[$key]%%|*}"
  body="## Description\n${epics[$key]#*|}"
  gh issue create \
    --title "$title" \
    --body "$body" \
    --label "epic,backend,ai,priority-critical" \
    --assignee "$ASSIGNEE" \
    --repo "$REPO"
done

# =========================
# TASKS (فاز 1 نمونه)
# =========================

declare -A tasks
tasks["Install WSL2"]="## Description\nInstall WSL2 and Ubuntu on Windows.\n\n## Acceptance Criteria\n- Ubuntu terminal works\n- Can run bash commands"
tasks["Install Python & venv"]="## Description\nInstall Python 3.11 and create virtual environment.\n\n## Acceptance Criteria\n- Python 3.11 installed\n- venv works"
tasks["Install CUDA & Drivers"]="## Description\nInstall NVIDIA CUDA toolkit and drivers for GPU.\n\n## Acceptance Criteria\n- nvidia-smi shows GPU\n- PyTorch CUDA available"
tasks["Install Python Packages"]="## Description\nInstall PyTorch, Transformers, bitsandbytes, accelerate.\n\n## Acceptance Criteria\n- Imports work\n- torch.cuda.is_available() == True"
tasks["Download & Test Mistral 7B"]="## Description\nDownload Mistral 7B Instruct 4bit and run test script.\n\n## Acceptance Criteria\n- Model loads on GPU\n- Generates output"
tasks["Create llm_engine module"]="## Description\nImplement model loading and generate() function.\n\n## Acceptance Criteria\n- Streaming generation works\n- Configurable temperature & max_tokens"
tasks["Create SQLAlchemy models"]="## Description\nCreate ChatSession and Message tables.\n\n## Acceptance Criteria\n- Tables created\n- CRUD works"
tasks["Create FastAPI endpoints"]="## Description\nEndpoints: create-session, list-sessions, chat, delete-session.\n\n## Acceptance Criteria\n- Each endpoint tested\n- Streaming response works"
tasks["Setup React Frontend"]="## Description\nInitialize Vite project and create basic UI.\n\n## Acceptance Criteria\n- Frontend starts\n- Can send requests to backend"

echo "Creating Tasks..."
for key in "${!tasks[@]}"; do
  title="[EPIC 0 / Task] $key"
  body="${tasks[$key]}"
  gh issue create \
    --title "$title" \
    --body "$body" \
    --label "task,backend,ai,priority-critical" \
    --assignee "$ASSIGNEE" \
    --repo "$REPO"
done

echo "All Epics and Tasks have been created!"