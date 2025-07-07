# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Multi-Agent AI Team System

This repository contains a tmux-based multi-agent AI collaboration system using Claude CLI. The system orchestrates 5 AI agents working together on projects across development, marketing, planning, and analysis.

### Core Architecture

The system follows a hierarchical delegation model:
- **CEO (ceo:0)**: Strategic decision-maker, delegates all work to Manager
- **Manager (team:0.0)**: Project coordinator, manages task dependencies and team allocation
- **3 Execution Agents (team:0.1-0.3)**: Flexible specialists adapting to project needs

### Key Commands

#### System Setup
```bash
# Start the AI team system
./start-ai-team.sh

# Initialize all agents with their roles
./initialize-agents.sh

# Stop the entire system
tmux kill-server
```

#### Inter-Agent Communication
```bash
# Send message to specific agent
./send-message.sh [agent_name] "[message]"

# Available agents: ceo, manager, dev1, dev2, dev3
./send-message.sh manager "Start new project..."

# List all agents
./send-message.sh --list
```

#### Session Management
```bash
# Connect to CEO (strategic decisions)
tmux attach -t ceo

# Connect to team workspace (4-pane view)
tmux attach -t team

# List active sessions
tmux list-sessions
```

### Agent Role Architecture

#### CEO Behavior Pattern
- **Never** performs direct work or coding
- **Always** delegates to Manager using structured format
- Provides final approval after Manager completion reports
- Follows strict delegation protocols in `instructions/ceo.md`

#### Manager Workflow System
- Receives CEO delegation and breaks down into tasks
- Analyzes task dependencies (parallel/sequential/mixed execution)
- Dynamically assigns roles to dev agents based on project type
- **Critical**: Must respond to completion reports with next actions
- Implements automatic workflow progression

#### Execution Agent Adaptability
- **dev1**: UI/UX, frontend, marketing, design focus
- **dev2**: Backend, infrastructure, data analysis, strategy focus  
- **dev3**: Quality management, testing, research, operations focus
- **Must** send completion reports to Manager using `./send-message.sh`

### Task Dependency Management

The Manager implements three execution strategies:

1. **Parallel Execution**: Independent tasks run simultaneously
2. **Sequential Execution**: Tasks depend on previous completion
3. **Partial Parallel**: Mixed approach with staged dependencies

### Communication Protocol

All agent communication is logged to `logs/communication.log`. Critical message patterns:
- `【プロジェクト開始指示】` - CEO to Manager delegation
- `【完了報告】` - Agent to Manager completion reports
- `【プロジェクト完了報告】` - Manager to CEO final reports

### File Structure

```
instructions/          # Agent role definitions
├── ceo.md            # CEO behavior and delegation patterns
├── manager.md        # Manager workflow and dependency management
└── developer.md      # Execution agent adaptability guidelines

logs/
└── communication.log # Complete inter-agent communication history

*.sh                  # System control scripts
```

### Agent Initialization

Each agent is initialized with Claude CLI using role-specific instruction files:
- CEO: `claude --dangerously-skip-permissions instructions/ceo.md`
- Manager: `claude --dangerously-skip-permissions instructions/manager.md`  
- Dev agents: `claude --dangerously-skip-permissions instructions/developer.md`

### System Monitoring

The system maintains persistent tmux sessions allowing real-time monitoring of:
- Individual agent progress
- Inter-agent communication flow
- Task completion status
- Workflow dependency resolution

Communication failures trigger escalation protocols defined in agent instruction files.

### Project Types Supported

The system dynamically adapts to handle:
- Software development (frontend/backend/testing)
- Marketing campaigns (research/strategy/content)
- Business planning (analysis/strategy/documentation)
- Research projects (investigation/analysis/reporting)

Role assignment is determined by Manager based on project requirements and agent specializations.