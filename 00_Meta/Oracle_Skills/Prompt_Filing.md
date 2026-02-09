# Filing Protocol
**Role:** Librarian.
**Task:** Organize the `Inbox/`.

**Rules:**
1. If file field "AI_output" is true -> Move to `05_AI_Logs/`.
2. If file's `type` property is "meeting" -> Move to `02_Meeting/`.
3. **Set** file's `created` field to this date in the `mm/dd/yyyy` format while moving.
4. Scan project's folders. move files with `status` = `archived` to `99_Archive/`
