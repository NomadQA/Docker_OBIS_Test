FROM python:3.14-slim-trixie

# Avoid prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
    wget curl unzip gnupg ca-certificates \
    git \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libgbm1 \
    libgtk-4-1 \
    libnss3 \
    libu2f-udev \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Add Google Chrome repo and keyrings
RUN mkdir -p /etc/apt/keyrings && \
    wget -q -O /etc/apt/keyrings/google-chrome.gpg \
        https://dl.google.com/linux/linux_signing_key.pub && \
    chmod 644 /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] \
        http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list
        
# Install Chrome
RUN apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /opt/google/chrome /usr/bin/google-chrome

# Download and extract latest Firefox
RUN install -d -m 0755 /etc/apt/keyrings
RUN wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

RUN cat <<EOF | tee /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF

RUN apt-get update \
    && apt-get install -y firefox

# Create user and workspace
WORKDIR /home/tester
RUN useradd tester
RUN chown -R tester:tester /home/tester
USER tester

# Default Chrome options for Docker
ENV ROBOT_SYSLOG_FILE=/dev/null
ENV CHROME_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --headless=new"
ENV PATH="$PATH:/home/tester/OBISAutomationSuite/venv/bin:/home/tester/.local/bin:/usr/bin:/usr/bin/google-chrome"

# Clone OBISAutomationSuite
RUN git clone https://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:x-oauth-basic@github.com/NomadQA/OBISAutomationSuite.git

# Install OBIS Automation Suite
RUN cd /home/tester/OBISAutomationSuite \
    && python -m venv venv \
    && chmod +x venv/bin/activate \
    && ./venv/bin/activate \
    && python -m pip install --upgrade pip \
    && pip install -r requirements

# These help during a failure
RUN pip list
RUN firefox --version
RUN chrome --version

WORKDIR /home/tester/OBISAutomationSuite

# Run robot asdefaul endpoint
ENTRYPOINT ["robot"]