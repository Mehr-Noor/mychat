#!/bin/bash

# CONFIG
REPO="Mehr-Noor/mychat"
ASSIGNEE="Mehr-Noor"

# LABELS
labels=("epic" "task" "backend" "ai" "priority-critical")
for label in "${labels[@]}"; do
    if ! gh label list --repo "$REPO" | grep -qw "$label"; then
        gh label create "$label" --repo "$REPO" --color "ffffff" --description "$label label"
    fi
done

# EPICS in order
declare -A epics
epics["EPIC 0"]="Environment Setup|Setup WSL2, Python environment, CUDA, dependencies, and folder structure."
epics["EPIC 1"]="LLM Engine Layer|Tasks related to model loading, streaming, inference logic, and GPU memory."
epics["EPIC 2"]="Database & Session Management|Design DB schema, session CRUD, message CRUD, tests."
epics["EPIC 3"]="FastAPI Backend|Endpoints, streaming, CORS, error handling, logging."
epics["EPIC 4"]="React Frontend|UI components, multi-session support, streaming, sidebar."

epic_order=("EPIC 0" "EPIC 1" "EPIC 2" "EPIC 3" "EPIC 4")
declare -A epic_ids

# TASKS per Epic
declare -A tasks
tasks["EPIC 0"]="Install WSL2|Install Python & venv|Install CUDA & Drivers|Install Python Packages"
tasks["EPIC 1"]="Download & Test Mistral 7B|Create llm_engine module"
tasks["EPIC 2"]="Create SQLAlchemy models"
tasks["EPIC 3"]="Create FastAPI endpoints"
tasks["EPIC 4"]="Setup React Frontend"

declare -A task_descriptions
task_descriptions["Install WSL2"]="Initialize WSL2 and Ubuntu on Windows.\n\n## Acceptance Criteria\n- Ubuntu terminal works\n- Can run bash commands"
task_descriptions["Install Python & venv"]="Install Python 3.11 and create virtual environment.\n\n## Acceptance Criteria\n- Python 3.11 installed\n- venv works"
task_descriptions["Install CUDA & Drivers"]="Install NVIDIA CUDA toolkit and drivers.\n\n## Acceptance Criteria\n- nvidia-smi shows GPU\n- PyTorch CUDA available"
task_descriptions["Install Python Packages"]="Install PyTorch, Transformers, bitsandbytes, accelerate.\n\n## Acceptance Criteria\n- Imports work\n- torch.cuda.is_available() == True"
task_descriptions["Download & Test Mistral 7B"]="Download Mistral 7B Instruct 4bit and run test script.\n\n## Acceptance Criteria\n- Model loads on GPU\n- Generates output"
task_descriptions["Create llm_engine module"]="Implement model loading and generate() function.\n\n## Acceptance Criteria\n- Streaming generation works\n- Configurable temperature & max_tokens"
task_descriptions["Create SQLAlchemy models"]="Create ChatSession and Message tables.\n\n## Acceptance Criteria\n- Tables created\n- CRUD works"
task_descriptions["Create FastAPI endpoints"]="Endpoints: create-session, list-sessions, chat, delete-session.\n\n## Acceptance Criteria\n- Each endpoint tested\n- Streaming response works"
task_descriptions["Setup React Frontend"]="Initialize Vite project and create basic UI.\n\n## Acceptance Criteria\n- Frontend starts\n- Can send requests to backend"

# CREATE EPICS AND TASKS WITH GLOBAL NUMBERING
task_counter=1

for epic_key in "${epic_order[@]}"; do
    epic_title="[${epic_key}] ${epics[$epic_key]%%|*}"
    epic_body="${epics[$epic_key]#*|}"

    # Create Epic
    epic_number=$(gh issue create \
        --title "$epic_title" \
        --body "$(cat <<EOF
## Description
$epic_body
EOF
)" \
        --label "epic,backend,ai,priority-critical" \
        --assignee "$ASSIGNEE" \
        --repo "$REPO" \
        --json number | jq -r '.number')
    epic_ids[$epic_key]=$epic_number
    echo "Created Epic: $epic_title #$epic_number"

    # Create Tasks
    IFS='|' read -ra task_list <<< "${tasks[$epic_key]}"
    for task in "${task_list[@]}"; do
        task_title="[Task $task_counter] $task"
        task_body="${task_descriptions[$task]}"

        gh issue create \
            --title "$task_title" \
            --body "$(cat <<EOF
## Description
$task_body

Related Epic: #$epic_number
EOF
)" \
            --label "task,backend,ai,priority-critical" \
            --assignee "$ASSIGNEE" \
            --repo "$REPO"

        echo "Created Task: $task_title linked to Epic #$epic_number"
        ((task_counter++))
    done
done

echo "✅ All Epics and Tasks created in proper order with numbering!"