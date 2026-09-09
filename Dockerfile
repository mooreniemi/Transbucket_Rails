FROM ruby:3.1.6

# ruby:3.1.6 is based on Debian 12 (bookworm), which is still current, so no
# archive.debian.org repointing is needed here (unlike the old ruby:2.6.6
# image, which was based on the now-EOL Debian 10 buster).
RUN apt-get -yqq update \
    && apt-get -yqq install nodejs postgresql-client

# Chrome for Testing only publishes a linux64 (x86_64) chromedriver -- no
# linux-arm64 build exists -- so pairing it with google-chrome-stable breaks
# on arm64 hosts (e.g. Apple Silicon), where the browser installs natively
# but the driver can only run under x86_64 emulation, which fails to find
# its own dynamic linker in this image's arm64 rootfs. Installing chromium
# and chromium-driver together from the same apt transaction gives a
# natively-built, version-matched browser/driver pair on every architecture
# this image supports, with no emulation involved.
RUN apt-get -yqq install chromium chromium-driver \
    && rm -rf /var/lib/apt/lists/* \
    && chromium --version \
    && chromedriver --version

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN echo -n "nproc = " && nproc && bundle install -j$(nproc)
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
