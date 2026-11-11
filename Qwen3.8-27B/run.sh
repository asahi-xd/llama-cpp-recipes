#!/bin/sh

# Qwen3.8 27B, IQ3_XXS, q8_0/q5_1 KV cache. Runs in a single RTX 3060 12GB, with ~21 tokens/s. For 63k context, need to run headless inside a tty.
# DO NOT bother with lowering the Key cache quantization further. The lowest I'd go is q5_1 for both K and V, but that causes noticeable hallucinations (wrong grammar, forgets things, etc).
# Only do that if you are _really_ desperate...

llama-server \
  -m "$LLM_Weights/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF/Qwen3.8-27B-GSQ-RCO-IQ3_XXS.gguf" \
  --mmproj "$LLM_Weights/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF/mmproj-Qwen3.8-27B-BF16.gguf" --no-mmproj-offload \
  --alias "Qwen3.8-27B" --api-key "$LLAMA_PASSWORD" \
  -c 63232 -ngl all -fa on -np 1 -kvu -t 6 \
  --ctx-checkpoints 32 --cache-ram 8192 -ctk q8_0 -ctv q5_1 \
  --host 127.0.0.1 --port 1234 \
  --temp 1.0 --top-k 20 --top-p 0.95 --min-p 0.0 --presence-penalty 0.0 --repeat-penalty 1.0 \
  --batch-size 2048 --ubatch-size 512 --image-min-tokens 1024 \
  --jinja --chat-template-file "$LLM_Weights/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF/chat_template.jinja" \
  --chat-template-kwargs "{\"preserve_thinking\":false}" --no-reasoning-preserve --reasoning-effort low \
  --load-mode none --reasoning-budget 8192 \
  --webui-mcp-proxy --webui-config-file "$HOME/.local/llama.cpp-configs/webui.json" \
  --tools get_info --cors-origins "http://localhost:1234,http://127.0.0.1:1234" \
  --reasoning-budget-message "[Reasoning budget reached. Your internal reasoning has been cut off by the system because it hit the token limit, not because you chose to stop. Do not continue reasoning or re-open the problem. In your response, briefly tell the user that the internal reasoning was cut short by the token budget, and whether you reached a solid conclusion or not. Then give the best answer you can from the reasoning done so far, and say clearly which parts, if any, are uncertain or unfinished.]"
  
