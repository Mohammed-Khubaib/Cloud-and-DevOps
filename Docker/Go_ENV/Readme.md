# Create an Environment For Go programming

<aside>
 <h2> 🧑‍💻 Code on Container Environment </h2>

Step 1 :

- create two files Docker-compose.yaml and Dockerfile
    - **Dockerfile :**
        
        ```docker
        FROM ubuntu
        
        RUN apt-get update && \
            apt-get install -y git golang
        
        WORKDIR /programs
        
        CMD tail -f /dev/null
        ```
        
    - **Docker-compose.yaml**
        
        ```yaml
        version: '3'
        
        services:
          go_env:
            image: ubuntu
            container_name: goenv
            volumes:
              - $HOME/Go_ENV:/programs
            working_dir: /programs
            command: tail -f /dev/null  # Keeps the container running indefinitely
        
            # Install Git and Golang during the container build process
            # You can modify these commands based on your specific requirements
            # or add additional installation steps as needed.
            # You can also replace the 'apt-get' commands with 'apt' if using Ubuntu 20.04 or newer.
            build:
              context: .
              dockerfile: Dockerfile
        ```
        

step 2 :

- Build the image :
    
    ```bash
    docker-compose up -d
    ```
    
    - check if the container is running in background :
        - in case the container in not running : run the following command :
            
            ```bash
            docker start goenv
            ```
            
- run the container form that image :
    
    ```bash
    docker exec -it goenv bash
    ```
    
</aside>
