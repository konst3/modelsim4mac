FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    libc6:i386 libstdc++6:i386 libncurses5:i386 libxft2:i386 libxext6:i386 \
    libx11-6:i386 libxtst6:i386 libfreetype6:i386 libfontconfig1:i386 lib32z1 \
    && rm -rf /var/lib/apt/lists/*
COPY ModelSimSetup-*-linux.run /tmp/ms.run
RUN chmod +x /tmp/ms.run && \
    /tmp/ms.run --mode unattended --accept_eula 1 \
      --modelsim_edition modelsim_ase --installdir /opt/intelFPGA && \
    rm /tmp/ms.run && \
    sed -i 's/linux_rh60/linux/g' /opt/intelFPGA/modelsim_ase/vco
ENV PATH=/opt/intelFPGA/modelsim_ase/bin:$PATH
WORKDIR /work
CMD ["vsim"]
