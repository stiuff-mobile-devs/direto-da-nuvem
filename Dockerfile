# Use a base image with Flutter preinstalled (we'll override to get a specific version)
FROM ubuntu:22.04

# Set environment variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk \
    FLUTTER_HOME=/opt/flutter \
    PATH="$PATH:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip git xz-utils zip libglu1-mesa openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /opt/flutter \
    && cd /opt/flutter \
    && git checkout 3.19.6 \
    && flutter doctor

# Accept Android SDK licenses
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && cd $ANDROID_SDK_ROOT/cmdline-tools \
    && curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip \
    && unzip sdk-tools.zip -d latest \
    && rm sdk-tools.zip

# Install Android SDK components
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Pre-cache Flutter dependencies
RUN flutter doctor -v

# Set working directory
WORKDIR /app
