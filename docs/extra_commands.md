# Extra commands

* Detailed List of all present volumes :

        docker volume ls -q | awk "{print $2}" | xargs docker volume inspect