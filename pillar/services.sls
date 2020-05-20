microservices:
  app_service:
    hostname: app_service
    # ssl_certificate:
    # ssl_force:
    # ssl_force:
    # ssl_key:
    containers:
      app:
        docker_image: app:latest
        base_port: 5432
        http_internal_port: 5432
        http: True
        stateful: False
        instances: 4
        command: ["./app.py"]
        environment:
          DB_ROOT_PASSWORD: supersupersecret
          DB_PASSWORD: supersecret
          DB_USER: myapp
          DB_DATABASE: myapp
        instances:
        links:
          database: db
        restart: always
      db:
        instances: 1
        docker_image: mariadb:10
        stateful: True
        volumes:
          - ["database", "/var/lib/mysql", "rw"]
        environment:
          MYSQL_ROOT_PASSWORD: supersupersecret
          MYSQL_PASSWORD: supersecret
          MYSQL_USER: myapp
          MYSQL_DATABASE: myapp

#      <example>:
#        docker_image: 
#        base_port:
#        http_internal_port:
#        stateful:
#        check_url:
#        command:
#        environment:
#        instances:
#        links:
#        restart:
#        stateful:
#        user:
#        volumes:
#        volumes_from:
#        http:
#        tcp_ports:
