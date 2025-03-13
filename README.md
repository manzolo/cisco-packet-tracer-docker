# Cisco Packet Tracer Docker Image

This repository contains a Dockerfile for building a Docker image of Cisco Packet Tracer.

## Prerequisites

* Docker installed on your system.
* **Cisco Packet Tracer `.deb` package:** You must download the official Cisco Packet Tracer `.deb` package from the [official Cisco Networking Academy website](https://www.netacad.com/). Due to licensing restrictions, this repository cannot provide the Packet Tracer software.

## Instructions

1.  **Download Packet Tracer:**
    * Go to the official Cisco Networking Academy website and download the `.deb` package for your architecture (usually AMD64).
2.  **Place Files:**
    * Place the downloaded `Packet_Tracer822_amd64_signed.deb` file in the same directory as the `Dockerfile`.
3.  **Build the Image:**
    * Open a terminal in the directory containing the `Dockerfile`.
    * Run the following command to build the Docker image:

    ```bash
    docker build -t manzolo/cisco-packet-tracer .
    ```

4.  **Run the Container:**
    * After the image is built, run the container with X11 forwarding:

    ```bash
    xhost +local:docker
    docker run -it --rm \
      -e DISPLAY=$DISPLAY \
      -v ./storage:/home/pt/storage \
      -v ./saves:/home/pt/pt/saves \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      manzolo/cisco-packet-tracer
    xhost -local:docker
    ```

    * Alternatively, you can use the provided `menu.sh` script for a menu driven experience.

5.  **Enter Container Shell**
    * If you used the `menu.sh` script, you can enter the running container shell by selecting option 3 from the menu.
    * If you ran the container manually, you can enter with:
        ```bash
        docker exec -it <container_id_or_name> bash
        ```

## Volumes

* `./storage:/home/pt/storage`: Persists the Packet Tracer configuration and user data.
* `./saves:/home/pt/pt/saves`: Persists Packet Tracer simulation files.

## Important Notes

* This Dockerfile uses `DEBIAN_FRONTEND=noninteractive` to automate the installation.
* The script verifies the sha256 checksum of the deb file before installing.
* X11 forwarding is required to display the Packet Tracer GUI.
* Remember to replace `Packet_Tracer822_amd64_signed.deb` with the actual filename of your Packet Tracer package.
* This repository does not provide Packet Tracer software due to licensing restrictions.
