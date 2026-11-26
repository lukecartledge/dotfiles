import { Plugin } from "@opencode/plugin"
import { stripArtifactsInstruction } from "./filter"

// Drops only Atlassian MCP's "ask to upload to Atlassian Artifacts" instruction from outgoing model context.
export default Plugin.define({
  id: "local.atlassian-artifacts-prompt",
  async setup(ctx) {
    await ctx.session.hook("context", (event) => {
      for (const part of event.system) {
        if (part.type === "text") part.text = stripArtifactsInstruction(part.text)
      }
    })
  },
})
