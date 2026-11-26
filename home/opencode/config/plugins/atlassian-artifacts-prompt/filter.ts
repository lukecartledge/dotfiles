export const ARTIFACTS_INSTRUCTION =
  "When creating an HTML or text-based file, always ask the user whether they would like to upload it to Atlassian Artifacts. If they do, use `discover` to retrieve `createArtifactsUpload` (step 1) and `publishArtifact` (step 2)."

const ATLASSIAN_BLOCK = /(<server name="atlassian">)([\s\S]*?)(<\/server>)/g

// Remove the exact sentence. If it is alone on its line, remove the whole line (indent and one line break).
const stripFromBody = (body: string) => {
  const i = body.indexOf(ARTIFACTS_INSTRUCTION)
  if (i === -1) return body
  const end = i + ARTIFACTS_INSTRUCTION.length
  const lineStart = body.lastIndexOf("\n", i - 1) + 1
  const nl = body.indexOf("\n", end)
  const lineEnd = nl === -1 ? body.length : nl
  const alone = /^[ \t]*$/.test(body.slice(lineStart, i)) && /^[ \t]*$/.test(body.slice(end, lineEnd))
  if (!alone) return body.slice(0, i) + body.slice(end)
  if (nl !== -1) return body.slice(0, lineStart) + body.slice(nl + 1)
  return body.slice(0, Math.max(0, lineStart - 1)) + body.slice(lineEnd)
}

const MCP_SECTION = /<mcp_instructions>[\s\S]*?<\/mcp_instructions>/g

export const stripArtifactsInstruction = (text: string) =>
  text.replace(MCP_SECTION, (section) =>
    section.replace(ATLASSIAN_BLOCK, (_m, open: string, body: string, close: string) => open + stripFromBody(body) + close),
  )
