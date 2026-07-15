import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const baseUrl = "https://chatgpt.com/backend-api";
const api = "openai-codex-responses" as const;

export default function (pi: ExtensionAPI) {
  // Providing models replaces Pi's built-in list for this provider. The API-key
  // placeholder satisfies provider registration; normal openai-codex OAuth
  // credentials still take precedence when requests are made.
  pi.registerProvider("openai-codex", {
    baseUrl,
    api,
    apiKey: "$OPENAI_CODEX_API_KEY",
    models: [
      {
        id: "gpt-5.6-sol",
        name: "GPT-5.6-Sol",
        reasoning: true,
        thinkingLevelMap: {
          off: null,
          minimal: "low",
          xhigh: "xhigh",
        },
        input: ["text", "image"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 272000,
        maxTokens: 128000,
      },
      {
        id: "gpt-5.5",
        name: "GPT-5.5",
        reasoning: true,
        thinkingLevelMap: {
          minimal: "low",
          xhigh: "xhigh",
        },
        input: ["text", "image"],
        cost: { input: 5, output: 30, cacheRead: 0.5, cacheWrite: 0 },
        contextWindow: 272000,
        maxTokens: 128000,
      },
    ],
  });
}
