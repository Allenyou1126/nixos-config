{ ... }:

{
  services.hermes-agent.settings.plugins.disabled = [
    # --- 所有内置 Web 搜索插件 ---
    "web-brave-free"
    "web-ddgs"
    "web-exa"
    "web-firecrawl"
    "web-keenable"
    "web-openai-native"
    "web-parallel"
    "web-perplexity"
    "web-searxng"
    "web-tavily"
    "web-xai"

    # --- 除 DeepSeek 外的模型/图像提供商 ---
    "deepinfra"
    "fal"
    "krea"
    "meta-ai-image-gen"
    "openai"
    "openai-codex"
    "openrouter"
    "xai"

    # --- 其他消息平台（保留 QQ Bot，禁用其余） ---
    "a2a-platform"
    "bluebubbles-platform"
    "buzz-platform"
    "dingtalk-platform"
    "discord-platform"
    "email-platform"
    "feishu-platform"
    "google_chat-platform"
    "irc-platform"
    "line-platform"
    "matrix-platform"
    "mattermost-platform"
    "ntfy-platform"
    "photon-platform"
    "raft-platform"
    "signal-platform"
    "simplex-platform"
    "slack-platform"
    "sms-platform"
    "teams-platform"
    "telegram-platform"
    "wecom-platform"
    "weixin-platform"
    "whatsapp-platform"
    "whatsapp_cloud-platform"
    "yuanbao-platform"
  ];
}
