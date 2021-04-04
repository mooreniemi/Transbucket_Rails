FROM ruby:2.6.6

RUN apt-get -yqq update && apt-get -yqq install nodejs postgresql-client

RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -yqq update && \
    apt-get -yqq install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --no-sandbox|g' "/opt/google/chrome/google-chrome" && \
    google-chrome --version

RUN CHROME_VERSION="$(google-chrome --version)" \
    && export CHROMEDRIVER_RELEASE="$(echo $CHROME_VERSION | sed 's/^Google Chrome //')" && export CHROMEDRIVER_RELEASE=${CHROMEDRIVER_RELEASE%%.*} \
    && CHROMEDRIVER_VERSION=$(curl --silent --show-error --location --fail --retry 4 --retry-delay 5 http://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_RELEASE}) \
    && curl --silent --show-error --location --fail --retry 4 --retry-delay 5 --output /tmp/chromedriver_linux64.zip "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" \
    && cd /tmp \
    && unzip chromedriver_linux64.zip \
    && rm -rf chromedriver_linux64.zip \
    && mv chromedriver /usr/local/bin/chromedriver \
    && chmod +x /usr/local/bin/chromedriver \
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
