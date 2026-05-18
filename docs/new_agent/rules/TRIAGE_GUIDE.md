📖 BACKLOG TRIAGE OPERATIONAL GUIDE
Path: docs/new_agent/rules/TRIAGE_GUIDE.md

Objective: Convert legacy backlog ideas into high-fidelity, verified 0x task blueprints using local models today, preparing a friction-free sprint path for high-tier cloud models/Copilot tomorrow.

🔁 The JIT Triage Loop Diagram
The workflow follows a strict stage-gate process to ensure we do not waste cloud tokens or local compute on stale code definitions:

[Legacy Backlog File] 
         │
         ▼
[Step 1: Extracted Seed Data] ──► Fed into Local Continue Sidebar
         │
         ▼
[Step 2: Verification Ledger] ──► Local Agent indexes active workspace
         │
         ├──► FOUND: Map directly to Primary Files Table
         └──► MISSING: Flag as Greenfield creation task
         │
         ▼
[Step 3: Synthesis Pass] ───────► Build modern 0x Markdown Task File
         │
         ▼
[Step 4: Active Queue] ────────► Hand task to GitHub Copilot for code generation
🛠️ Step-by-Step Execution Protocol
Step 1: Extract the Legacy Seed Data
Do not run bulk scripts. Open one single file from your reorganization_attempt_2/ or legacy backup folder. Identify the bare essentials:

What was the core engineering intent?

What specific files or directories did it think it needed?

Step 2: The Sidebar Verification Prompt
Open your Continue sidebar chat, select DeepSeek 16B (or your active local logic model), and pin your master template using @TASK_TEMPLATE.md. Paste the standardized engineering prompt layout below.

⚠️ CRITICAL RULES:

You must explicitly demand the Verification Ledger right at the top. This forces the local model to parse your editor's active workspace index before writing text.

Explicitly command the model to output text only to bypass Ollama registry tool-calling config errors.

📋 Standardized Prompt Template:
Plaintext
You are a Lead Software Architect. We are executing a single-file textual triage of a legacy feature concept. 

CRITICAL PROTOCOL: Before generating the task file, you must output a "Codebase Verification Ledger" where you compare the old paths against our active workspace context to determine ground truth.

LEGACY DATA:
- Feature Name: [Insert Feature Name]
- Old File Path: [Insert Old Filename.md]
- Core Intent: [Insert 1-2 sentences of what the feature should calculate/do]
- Associated Old Paths:
  * [List path 1]
  * [List path 2]

INSTRUCTIONS:
1. Output the "Codebase Verification Ledger" indicating if these paths are FOUND, MISSING, or require GREENFIELD creation.
2. Generate a brand new, clean task file matching @TASK_TEMPLATE.md exactly.
3. In the "Files Involved" section, separate files to edit (Primary) from directory/config contexts (Reference).
4. In the "Dependencies" section, explicitly list the legacy filename as blocked for removal upon completion.

Output your ledger and the clean markdown block now. Do not call system tools.
Step 3: Audit & Save to Backlog
When the local model responds in the sidebar:

Check the Ledger: Did the agent correctly spot if files are missing or present?

Strip Hallucinated Completions: Ensure the Synthesis Report block at the bottom of the generated task is a blank layout template, not pre-filled text.

Save it: Create a new file in docs/new_agent/tasks/backlog/ using the mandatory naming convention: YYYY-MM-DD-PRIORITY-TYPE-NAME.md.

Step 4: The Cloud Sprint (Tomorrow's Copilot Burn)
When you sit down tomorrow to clear your weekly Copilot allocation:

Open your freshly minted, verified task file.

Open the primary target file you want to edit (e.g., app/services/...).

Highlight the specific Implementation Step in the task file, open Copilot Chat, and command:

"Implement Step X of this active workspace file exactly as specified in our 0x task blueprint."

Run your isolated Docker RSpec container command provided in the task file to verify.

Delete the old legacy file tagged in the Dependencies section to permanently clear your backlog debt.