FROM python:3.8-slim-buster

RUN set -ex \
  && apt-get update \
  && apt update \
  && apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio -y \
  && apt install libgirepository1.0-dev gcc libcairo2-dev pkg-config python3-dev gir1.2-gtk-3.0 -y \
  && pip3 install pycairo PyGObject mopidy-iris mopidy-qobuz-hires mopidy-local \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
  && mkdir -p /var/lib/mopidy/.config \
  && ln -s /config /var/lib/mopidy/.config/mopidy


# Start helper script.
COPY entrypoint.sh /entrypoint.sh

# Default configuration.
COPY mopidy.conf /config/mopidy.conf
#COPY mopidy.conf /var/lib/mopidy/.config/mopidy

# Copy the pulse-client configuratrion.
COPY pulse-client.conf /etc/pulse/client.conf

ENV HOME=/var/lib/mopidy
VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680 5555/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mopidy","--config","/config/mopidy.conf"]

HEALTHCHECK --interval=5s --timeout=2s --retries=20 \
    CMD curl --connect-timeout 5 --silent --show-error --fail http://localhost:6680/ || exit 1
