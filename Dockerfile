FROM ghcr.io/astral-sh/uv:python3.12-bookworm

# Keep default PyPI (remove Aliyun mirror config)

# (Removed the pip.conf lines)

# Use default Debian repositories (remove Aliyun sed rewrites)

RUN apt-get update  
RUN apt-get install ffmpeg -y  
RUN apt-get clean

# Workdir

WORKDIR /gpt

# Pre-install dependencies using cache

COPY requirements.txt ./  
RUN uv venv --python=3.12 && uv pip install --verbose -r requirements.txt  
ENV PATH="/gpt/.venv/bin:$PATH"  
RUN python -c 'import loguru'

# Project files and remaining deps

COPY . .  
RUN uv pip install -r requirements.txt

# Optional warm-up

RUN python -c 'from check_proxy import warm_up_modules; warm_up_modules()'

ENV CGO_ENABLED=0

# Start

CMD ["bash", "-c", "python main.py"]
