#!/bin/bash

# =============================
# CONFIGURATION
# =============================
REPO="Mehr-Noor/mychat"        # تغییر بده به OWNER/REPO خودت
ASSIGNEE="Mehr-Noor"           # تغییر بده به GitHub username خودت

# =============================
# LABELS
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
# TASKS per Epic with numbering
# =============================
declare -A tasks
# Format: tasks["EpicKey"]="Task1|Task2|Task3"
tasks["EPIC 1"]="Install WSL2|Install Python & venv|Install CUDA & Drivers|Install Python Packages"
tasks["EPIC 2"]="Download & Test Mistral 7B|Create llm_engine module"
tasks["EPIC 3"]="Create SQLAlchemy models"
tasks["EPIC 4"]="Create FastAPI endpoints"
tasks["EPIC 5"]="Setup React Frontend"

# Example: Description & Acceptance Criteria (simple for demo)
declare -A task_descriptions
task_descriptions["Install WSL2"]="## Description\nInstall WSL2 and Ubuntu on Windows.\n\n## Acceptance Criteria\n- Ubuntu terminal works\n- Can run bash commands"
task_descriptions["Install Python & venv"]="## Description\nInstall Python 3.11 and create virtual environment.\n\n## Acceptance Criteria\n- Python 3.11 installed\n- venv works"
task_descriptions["Install CUDA & Drivers"]="## Description\nInstall NVIDIA CUDA toolkit and drivers for GPU.\n\n## Acceptance Criteria\n- nvidia-smi shows GPU\n- PyTorch CUDA available"
task_descriptions["Install Python Packages"]="## Description\nInstall PyTorch, Transformers, bitsandbytes, accelerate.\n\n## Acceptance Criteria\n- Imports work\n- torch.cuda.is_available() == True"
task_descriptions["Download & Test Mistral 7B"]="## Description\nDownload Mistral 7B Instruct 4bit and run test script.\n\n## Acceptance Criteria\n- Model loads on GPU\n- Generates output"
task_descriptions["Create llm_engine module"]="## Description\nImplement model loading and generate() function.\n\n## Acceptance Criteria\n- Streaming generation works\n- Configurable temperature & max_tokens"
task_descriptions["Create SQLAlchemy models"]="## Description\nCreate ChatSession and Message tables.\n\n## Acceptance Criteria\n- Tables created\n- CRUD works"
task_descriptions["Create FastAPI endpoints"]="## Description\nEndpoints: create-session, list-sessions, chat, delete-session.\n\n## Acceptance Criteria\n- Each endpoint tested\n- Streaming response works"
task_descriptions["Setup React Frontend"]="## Description\nInitialize Vite project and create basic UI.\n\n## Acceptance Criteria\n- Frontend starts\n- Can send requests to backend"

echo "Creating Tasks with numbering..."
for epic_key in "${!tasks[@]}"; do
  IFS='|' read -ra task_list <<< "${tasks[$epic_key]}"
  epic_number=${epic_ids[$epic_key]}
  count=1
  for task in "${task_list[@]}"; do
    title="[Task $count] $task"
    body="${task_descriptions[$task]}

Related Epic: #$epic_number"
    
    gh issue create \
      --title "$title" \
      --body "$body" \
      --label "task,backend,ai,priority-critical" \
      --assignee "$ASSIGNEE" \
      --repo "$REPO"
    
    echo "Created Task: $title linked to Epic #$epic_number"
    ((count++))
  done
done

echo "All Epics and Tasks have been created successfully!"