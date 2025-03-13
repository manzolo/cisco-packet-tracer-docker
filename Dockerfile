FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Aggiorna i pacchetti e installa le dipendenze necessarie
RUN apt-get update && apt-get install -y \
    tar \
    wget \
    xauth \
    libqt5webkit5 \
    libqt5xml5 \
    libqt5multimedia5 \
    libqt5script5 \
    libqt5scripttools5 \
    sudo \
    libnss3 \
    libxss1 \
    libasound2 \
    vim \
    less \
    libgl1-mesa-glx \
    libglu1-mesa \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shm0 \
    libxcb-xfixes0 \
    dialog \
    xdg-utils \
    libxcb-xinerama0-dev \
    tzdata \
    debconf-utils \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
    echo "tzdata tzdata/Areas select Europe" | debconf-set-selections && \
    echo "tzdata tzdata/Zones/Europe select Rome" | debconf-set-selections && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Crea l'utente pt
RUN export uid=1000 gid=1000 \
    && mkdir -p /home/pt \
    && echo "pt:x:${uid}:${gid}:pt,,,:/home/pt:/bin/bash" >> /etc/passwd \
    && echo "pt:x:${uid}:" >> /etc/group \
    && mkdir /home/pt/storage \
    && chown ${uid}:${gid} -Rv /home/pt

# Copia il pacchetto Packet Tracer
COPY Packet_Tracer822_amd64_signed.deb /tmp/Packet_Tracer822_amd64_signed.deb
COPY Packet_Tracer822_amd64_signed.deb.sha256sum /tmp/Packet_Tracer822_amd64_signed.deb.sha256sum

RUN sed -i 's/ .*$//' /tmp/Packet_Tracer822_amd64_signed.deb.sha256sum && \
    bash -c 'if ! diff <(sha256sum /tmp/Packet_Tracer822_amd64_signed.deb | cut -d" " -f1) /tmp/Packet_Tracer822_amd64_signed.deb.sha256sum; then echo "Checksum FAILED" && exit 1; fi'
    
# Estrai e modifica il pacchetto per evitare l'EULA (installazione non interattiva)
RUN DEBIAN_FRONTEND=noninteractive mkdir -p pt_package/DEBIAN \
    && dpkg-deb -x /tmp/Packet_Tracer822_amd64_signed.deb /pt_package/ \
    && dpkg-deb -e /tmp/Packet_Tracer822_amd64_signed.deb /pt_package/DEBIAN/ \
    && rm -f /pt_package/DEBIAN/preinst \
    && dpkg-deb -Z xz -b /pt_package/ packettracer_8.2.2_amd64.deb \
    && dpkg -i /packettracer_8.2.2_amd64.deb \
    && rm -f /tmp/Packet_Tracer822_amd64_signed.deb \
    && rm -f /tmp/Packet_Tracer822_amd64_signed.deb.sha256sum \
    && rm -f /packettracer_8.2.2_amd64.deb \
    && rm -rf /pt_package \
    && chown ${uid}:${gid} -Rv /opt/pt

# Copia lo script di avvio
COPY packettracer /usr/local/bin/packettracer
RUN chmod +x /usr/local/bin/packettracer

# Configura l'utente e avvia Packet Tracer
USER pt
ENV HOME=/home/pt
CMD ["/usr/local/bin/packettracer"]