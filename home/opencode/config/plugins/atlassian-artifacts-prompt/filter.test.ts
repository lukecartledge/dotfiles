import { describe, expect, test } from "bun:test"
import { ARTIFACTS_INSTRUCTION, stripArtifactsInstruction } from "./filter"

const other = "Use `discover` to find tools."
// Mirrors the real assembled format captured from a live OpenCode 2.4.2 request: indented lines.
const block = (name: string, ...lines: string[]) =>
  `  <server name="${name}">\n${lines.map((l) => `    ${l}`).join("\n")}\n  </server>`
const wrap = (...servers: string[]) => `<mcp_instructions>\n${servers.join("\n")}\n</mcp_instructions>`

describe("stripArtifactsInstruction", () => {
  test("removes only the artifacts instruction from the atlassian block", () => {
    const input = wrap(block("atlassian", other, ARTIFACTS_INSTRUCTION, "Another rule."))
    expect(stripArtifactsInstruction(input)).toBe(wrap(block("atlassian", other, "Another rule.")))
  })

  test("removes it when it is the whole body or last line", () => {
    expect(stripArtifactsInstruction(wrap(block("atlassian", ARTIFACTS_INSTRUCTION)))).toBe(
      wrap('  <server name="atlassian">\n  </server>'),
    )
    expect(stripArtifactsInstruction(wrap(block("atlassian", other, ARTIFACTS_INSTRUCTION)))).toBe(
      wrap(block("atlassian", other)),
    )
  })

  test("leaves the same sentence in other servers untouched", () => {
    const input = wrap(block("other", ARTIFACTS_INSTRUCTION), block("atlassian", other))
    expect(stripArtifactsInstruction(input)).toBe(input)
  })

  test("only edits the atlassian block when both contain it", () => {
    const input = wrap(block("other", ARTIFACTS_INSTRUCTION), block("atlassian", ARTIFACTS_INSTRUCTION, other))
    expect(stripArtifactsInstruction(input)).toBe(wrap(block("other", ARTIFACTS_INSTRUCTION), block("atlassian", other)))
  })

  test("removes the whole indented line without leaving stray whitespace", () => {
    const out = stripArtifactsInstruction(wrap(block("atlassian", "A", ARTIFACTS_INSTRUCTION, "B")))
    expect(out).toBe('<mcp_instructions>\n  <server name="atlassian">\n    A\n    B\n  </server>\n</mcp_instructions>')
  })

  test("removes only the sentence when it shares a line with other text", () => {
    const input = wrap(block("atlassian", `Lead. ${ARTIFACTS_INSTRUCTION}`))
    expect(stripArtifactsInstruction(input)).toBe(wrap(block("atlassian", "Lead. ")))
  })

  test("ignores the sentence outside any server block", () => {
    const input = `User said: ${ARTIFACTS_INSTRUCTION}`
    expect(stripArtifactsInstruction(input)).toBe(input)
  })

  test("requires an exact match (near variants preserved)", () => {
    const near = ARTIFACTS_INSTRUCTION.replace("always ask", "ask")
    const input = wrap(block("atlassian", near))
    expect(stripArtifactsInstruction(input)).toBe(input)
  })

  test("returns text without the instruction unchanged", () => {
    const input = wrap(block("atlassian", other))
    expect(stripArtifactsInstruction(input)).toBe(input)
  })

  test("only edits atlassian blocks inside <mcp_instructions>", () => {
    const outside = block("atlassian", ARTIFACTS_INSTRUCTION)
    const input = `${outside}\n${wrap(block("atlassian", ARTIFACTS_INSTRUCTION))}\n${outside}`
    expect(stripArtifactsInstruction(input)).toBe(`${outside}\n${wrap('  <server name="atlassian">\n  </server>')}\n${outside}`)
  })

  test("is idempotent", () => {
    const once = stripArtifactsInstruction(wrap(block("atlassian", other, ARTIFACTS_INSTRUCTION)))
    expect(stripArtifactsInstruction(once)).toBe(once)
  })
})
