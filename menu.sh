#!/bin/bash

# Function to build the Docker image
build_image() {
  docker build --progress=plain -t manzolo/cisco-packet-tracer .
}

# Function to run the Docker container with X11 forwarding and volumes
run_container() {
  xhost +local:docker
  docker run -it --name packettracer --rm \
    -e DISPLAY=$DISPLAY \
    -v ./storage:/home/pt/storage \
    -v ./saves:/home/pt/pt/saves \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    manzolo/cisco-packet-tracer
  xhost -local:docker
}

# Function to enter the Docker container shell
enter_container_shell() {
  docker exec -it packettracer bash
}

# Main menu
while true; do
  echo "Select an option:"
  echo "1. Build Docker image"
  echo "2. Run Docker container"
  echo "3. Enter container shell"
  echo "4. Exit"
  read -p "Enter your choice: " choice

  case $choice in
    1)
      build_image
      ;;
    2)
      run_container
      ;;
    3)
      enter_container_shell
      ;;
    4)
      break
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac
done
