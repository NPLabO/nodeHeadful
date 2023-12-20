FROM node:20.10.0
ARG TARGETPLATFORM
ARG BUILDPLATFORM
WORKDIR /home/nodeHeadful

USER root

# RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

RUN groupadd -r nodeHeadful
RUN useradd -r -g nodeHeadful -G audio,video,root,sudo nodeHeadful
# RUN usermod -a -G audio,video nodeHeadful
RUN mkdir -p /home/nodeHeadful/Downloads
RUN chown -R nodeHeadful:nodeHeadful /home/nodeHeadful

RUN mkdir -p ~/.config/fontconfig
COPY fonts.conf ~/.config/fontconfig
COPY startXvfb.sh .
COPY init.sh .
COPY initXvfb.sh .
# COPY systemctl.py /usr/bin/systemctl
COPY journalctl3.py /usr/bin/journalctl
COPY requirements.txt .
COPY systemctl3.py /usr/bin/systemctl
COPY xvfb.service /etc/systemd/system/xvfb.service

RUN  apt-get update \
     # && apt-get -y install systemd \
     && apt-get install xdg-user-dirs -yq \
     && apt-get install -yq python3-pip python3-dev libxml2-dev libxslt1-dev \
     && pip3 install filetype rarfile --break-system-packages \
     && chmod 777 /usr/bin/systemctl

#RUN test -L /bin/systemctl
#|| ln -sf /usr/bin/systemctl /bin/systemctl

RUN  apt-get update \
     && apt-get install -yq wget curl gnupg libgconf-2-4 ca-certificates wget xvfb dbus dbus-x11 build-essential --no-install-recommends \
     && apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcurl4-gnutls-dev libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-noto unzip --no-install-recommends \
     && cd "$(mktemp -d)" \
     && wget https://noto-website.storage.googleapis.com/pkgs/NotoColorEmoji-unhinted.zip \
     && unzip NotoColorEmoji-unhinted.zip \
     && mkdir -p ~/.fonts \
     && mv *.ttf ~/.fonts \
     && fc-cache -f -v \
     && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

RUN  apt-get update \
     && echo "arch=$(echo $TARGETPLATFORM | awk -F/ '{print $2}')" \
     && echo "deb [arch=$(echo $TARGETPLATFORM | awk -F/ '{print $2}')] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
     && apt-get update \
     && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 --no-install-recommends \
     && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/00-local-userns.conf
RUN service procps restart 2>/dev/null || service procps-ng restart 2>/dev/null || true
RUN echo '738a79fb44c24312b9c20910c18c0963' >> /etc/machine-id
# RUN truncate -s 0 /etc/apt/sources.list.d/google.list \
#      && apt-get update \
#      && apt-get install -yq python3-pip \
#      && pip3 install filetype rarfile --break-system-packages
# RUN google-chrome-stable --product-version | echo

# install requirements.txt
RUN pip3 install -r requirements.txt --break-system-packages

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/google-chrome-stable
ENV PUPPETEER_EXEC_PATH /usr/bin/google-chrome-stable
# google-chrome-stable
ENV DISPLAY :99

RUN bash initXvfb.sh

# CMD ["/bin/bash", "init.sh"]