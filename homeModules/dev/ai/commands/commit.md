---
description: Create a commit message
agent: plan
model: opencode-go/glm-5.1
---

# Generate commit message

## Description

Create new commit title and description. Answer with the commit message and description only nothing else.

## Commit template

```
type(scope): short summary

long summary (can be multiline)
```

## Important notes

- generate the commit message even if there isn't anything to commit
- limit the output to just the commit message
- this command will be used in a shell script
