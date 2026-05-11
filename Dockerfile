# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-gguf@1.1.10 --mode remote
RUN git clone https://github.com/cubiq/ComfyUI_essentials /comfyui/custom_nodes/ComfyUI_essentials && cd /comfyui/custom_nodes/ComfyUI_essentials && git checkout 9d9f4bedfc9f0321c19faf71855e228c93bd0dc9
RUN comfy node install --exit-on-fail comfyui-sam3@0.3.10
RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui /comfyui/custom_nodes/was-node-suite-comfyui && cd /comfyui/custom_nodes/was-node-suite-comfyui && git checkout ea935d1044ae5a26efa54ebeb18fe9020af49a45
RUN git clone https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/ComfyUI-KJNodes && cd /comfyui/custom_nodes/ComfyUI-KJNodes && git checkout 1ee6e3abb5b27625fe3b0ebf58716e333416b960

# download models into comfyui
RUN for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/unsloth/FLUX.2-klein-9B-GGUF/resolve/main/flux-2-klein-9b-Q4_0.gguf' --relative-path models/diffusion_models --filename 'flux-2-klein-9b-Q4_0.gguf' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; echo "model-download attempt $i failed; retrying in $((i*10))s" >&2; sleep $((i*10)); done
RUN for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Qwen/Qwen3-8B-GGUF/resolve/6a569868d07d3bd59e8b97fb001bf8c0b254bb20/Qwen3-8B-Q4_K_M.gguf' --relative-path models/diffusion_models --filename 'Qwen3-8B-Q4_K_M.gguf' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; echo "model-download attempt $i failed; retrying in $((i*10))s" >&2; sleep $((i*10)); done
RUN for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/bodhicitta/sam3/resolve/main/sam3.pt' --relative-path models/Unknown --filename 'models/sam3/sam3.pt' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; echo "model-download attempt $i failed; retrying in $((i*10))s" >&2; sleep $((i*10)); done
RUN for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors' --relative-path models/vae --filename 'flux2-vae.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; echo "model-download attempt $i failed; retrying in $((i*10))s" >&2; sleep $((i*10)); done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/2N0A0836copy.webp' "https://cool-anteater-319.convex.cloud/api/storage/42def995-cbc9-459c-817e-9198ca1e16fe"
