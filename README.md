# Docker_OBIS_Test
Simple docker container for running Robot Framework test cases using Selenium with Chrome and/or Firefox browsers.

## BUILD

```bash
docker build -t brian/obis --shm-size=1024m .
```

## RUN

```bash
docker run -it --shm-size=256m brian/obis -d Results Tests
```