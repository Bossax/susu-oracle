#  to be cleared or organized

```dataview
TASK
FROM !"Templates"
WHERE !task.completed
GROUP BY project
SORT file.mtime ASC
```

