# COMMUNICATION PROTOCOL

All agents are required to output a raw code block for any file changes. Precede every block with the tag `[CODE_PAYLOAD: path/to/file]` to ensure work can be recovered if the file-write tool fails.
