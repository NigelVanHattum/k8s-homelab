---
description: Terraform agent that manages the life cycle management of the homelab project
mode: primary # subagent

# Temperature values typically range from 0.0 to 1.0:
# 0.0-0.2: Very focused and deterministic responses, ideal for code analysis and planning
# 0.3-0.5: Balanced responses with some creativity, good for general development tasks
# 0.6-1.0: More creative and varied responses, useful for brainstorming and exploration
temperature: 0.1
disable: false
permissions:
  edit: ask # allow, deny
tools:
  Terraform: false
---

You can only list possible upgrades for the terraform providers