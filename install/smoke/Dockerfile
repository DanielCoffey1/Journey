# Smoke-test image for Journey Companion.
# Plain Arch + just enough tooling to exercise install.sh's non-package paths.
FROM archlinux:latest

# Refresh the package DB once and install the minimal set we need.
# diffutils → install.sh's `diff -rq` idempotency check
# awk/grep/sed/coreutils/findutils → install.sh and bin scripts
# git → ensure_git is a no-op when git is already present
# jq → exercised by journey-launch-or-focus and a handful of helpers
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
        sudo git bash awk grep sed coreutils findutils diffutils jq && \
    pacman -Scc --noconfirm

# Non-root user with passwordless sudo. install.sh's require_not_root + sudo
# keepalive both work cleanly against this.
RUN useradd -m -G wheel -s /bin/bash testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/00-testuser

USER testuser
WORKDIR /home/testuser

# Project source is copied in at build time so the test is reproducible
# without a network round-trip on every run.
COPY --chown=testuser:testuser . /home/testuser/journey-src

# JOURNEY_SKIP_PACKAGES=1 short-circuits the pacman/yay/systemctl phases of
# install.sh so the test stays fast and offline.
ENV JOURNEY_SKIP_PACKAGES=1
ENV JOURNEY_HOME=/home/testuser/.local/share/journey
ENV JOURNEY_CONFIG=/home/testuser/.config/journey

CMD ["bash", "/home/testuser/journey-src/install/smoke/test.sh"]
