# ============================================================
# R for VSCode — Development Container
# Features: R 4.4, Python 3.11, radian, Quarto, Git, Bash
# ============================================================
FROM ubuntu:22.04

# ── Environment ────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=UTC \
    QUARTO_VERSION=1.6.42 \
    PYTHON_VERSION=3.11

# ── Base system packages ────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    wget \
    curl \
    git \
    bash \
    ca-certificates \
    gnupg \
    lsb-release \
    locales \
    software-properties-common \
    apt-transport-https \
    # Locale
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# ── R from CRAN (signed-by keyring method) ────────────────
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
        | gpg --dearmor -o /etc/apt/keyrings/cran-archive-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/cran-archive-keyring.gpg] https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" \
        > /etc/apt/sources.list.d/cran.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

# ── System libraries required by common R packages ─────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # libcurl / openssl / xml — tidyverse / httr / xml2
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    # Font / Cairo — httpgd, ggplot2
    libfontconfig1-dev \
    libfreetype-dev \
    libcairo2-dev \
    libpango1.0-dev \
    # Other common deps
    libharfbuzz-dev \
    libfribidi-dev \
    libuv1-dev \
    libtiff-dev \
    libjpeg-dev \
    libpng-dev \
    # For compilation
    build-essential \
    gfortran \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# ── Python 3.11 + pip ──────────────────────────────────────
RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    python${PYTHON_VERSION}-dev \
    python3-pip \
    && update-alternatives --install /usr/bin/python  python  /usr/bin/python${PYTHON_VERSION} 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 \
    && rm -rf /var/lib/apt/lists/*

# ── radian — modern R console (via pip) ────────────────────
RUN pip3 install --no-cache-dir radian

# ── Quarto ─────────────────────────────────────────────────
RUN ARCH=$(dpkg --print-architecture) \
    && wget -q "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${ARCH}.deb" \
    && apt-get install -y "./quarto-${QUARTO_VERSION}-linux-${ARCH}.deb" \
    && rm "quarto-${QUARTO_VERSION}-linux-${ARCH}.deb" \
    && rm -rf /var/lib/apt/lists/*

# ── R packages ─────────────────────────────────────────────
# Install in one RUN to share the library cache layer.
# Mirrors: use CRAN cloud mirror for reliability.
RUN Rscript -e "\
    options(repos = c(CRAN = 'https://cloud.r-project.org'), Ncpus = 4L); \
    pkgs <- c( \
      'languageserver',   \
      'httpgd',           \
      'lintr',            \
      'styler',           \
      'rmarkdown',        \
      'knitr',            \
      'jsonlite',         \
      'httr',             \
      'devtools'          \
    ); \
    install.packages(pkgs) \
"

# ── Create non-root vscode user (devcontainer convention) ──
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} -s /bin/bash \
    # Allow vscode user to install R packages to the system library
    && chown -R ${USERNAME}:${USERNAME} /usr/local/lib/R \
    # Allow pip installs as user
    && mkdir -p /home/${USERNAME}/.local/bin \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# ── Workspace ──────────────────────────────────────────────
WORKDIR /workspace

# NOTE: Do NOT COPY . /workspace/ here.
# The devcontainer mounts the repo at /workspace via the volume in docker-compose.yml.
# Copying would create a stale snapshot that conflicts with live edits.

CMD ["/bin/bash"]
