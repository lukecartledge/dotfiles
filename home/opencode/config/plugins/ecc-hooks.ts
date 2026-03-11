import type { PluginInput, Hooks } from "@opencode-ai/plugin"

export const ECCHooksPlugin = async ({
  client,
  $,
  directory,
  worktree,
}: PluginInput): Promise<Hooks> => {
  const log = (level: "debug" | "info" | "warn" | "error", message: string) =>
    client.app.log({ body: { service: "ecc-hooks", level, message } })

  return {
    "tool.execute.after": async (input, output) => {
      const filePath = input.args?.filePath as string | undefined
      if (!filePath) return

      // TypeScript type-check after editing .ts/.tsx files
      if (input.tool === "edit" && filePath.match(/\.tsx?$/)) {
        try {
          await $`npx tsc --noEmit 2>&1`
          log("info", "[hooks] TypeScript check passed")
        } catch (error: unknown) {
          const err = error as { stdout?: string }
          log("warn", "[hooks] TypeScript errors detected:")
          if (err.stdout) {
            err.stdout.split("\n").slice(0, 5).forEach((line: string) =>
              log("warn", `  ${line}`)
            )
          }
        }
      }

      // Console.log warning after editing JS/TS files
      if (
        (input.tool === "edit" || input.tool === "write") &&
        filePath.match(/\.(ts|tsx|js|jsx)$/)
      ) {
        try {
          const result = await $`grep -n "console\\.log" ${filePath} 2>/dev/null`.text()
          if (result.trim()) {
            const count = result.trim().split("\n").length
            log("warn", `[hooks] console.log found in ${filePath} (${count} occurrence${count > 1 ? "s" : ""})`)
          }
        } catch {
          // grep returns non-zero when no match — this is fine
        }
      }

      // Auto-format JS/TS files with prettier after edits
      if (
        (input.tool === "edit" || input.tool === "write") &&
        filePath.match(/\.(ts|tsx|js|jsx)$/)
      ) {
        try {
          await $`prettier --write ${filePath} 2>/dev/null`
          log("info", `[hooks] Formatted: ${filePath}`)
        } catch {
          // prettier not installed or failed
        }
      }
    },

    "tool.execute.before": async (input, output) => {
      // Git push review reminder
      if (input.tool === "bash") {
        const cmd = String(output.args?.command || "")
        if (cmd.includes("git push")) {
          log("info", "[hooks] Remember to review changes before pushing: git diff origin/main...HEAD")
        }
      }

      // Warn about creating unnecessary documentation files
      if (input.tool === "write") {
        const fp = output.args?.filePath as string | undefined
        if (
          fp &&
          fp.match(/\.(md|txt)$/i) &&
          !fp.includes("README") &&
          !fp.includes("CHANGELOG") &&
          !fp.includes("LICENSE") &&
          !fp.includes("CONTRIBUTING")
        ) {
          log("warn", `[hooks] Creating ${fp} — consider if this documentation is necessary`)
        }
      }
    },

    "shell.env": async (_input, output) => {
      output.env.PROJECT_ROOT = worktree || directory

      // Detect package manager
      const lockfiles: Record<string, string> = {
        "bun.lockb": "bun",
        "pnpm-lock.yaml": "pnpm",
        "yarn.lock": "yarn",
        "package-lock.json": "npm",
      }
      for (const [lockfile, pm] of Object.entries(lockfiles)) {
        try {
          await $`test -f ${worktree}/${lockfile}`
          output.env.PACKAGE_MANAGER = pm
          break
        } catch {
          // not found
        }
      }

      // Detect languages
      const langDetectors: Record<string, string> = {
        "tsconfig.json": "typescript",
        "go.mod": "go",
        "pyproject.toml": "python",
        "Cargo.toml": "rust",
        "Package.swift": "swift",
      }
      const detected: string[] = []
      for (const [file, lang] of Object.entries(langDetectors)) {
        try {
          await $`test -f ${worktree}/${file}`
          detected.push(lang)
        } catch {
          // not found
        }
      }
      if (detected.length > 0) {
        output.env.DETECTED_LANGUAGES = detected.join(",")
        output.env.PRIMARY_LANGUAGE = detected[0]
      }
    },
  }
}

export default ECCHooksPlugin
