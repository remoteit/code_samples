This docker-compose launches a remoteit container as well as an echoeserver container.  It uses the following environment variables:

CONTAINER_NAME
R3_REGISTRATION_CODE

You can pass in these variable in a couple of ways as follows:

  1. Environment variables
  2. .env file

I prefer the .env file as it is always there and won't get checked into source code as we .gitignore .env files.

The R3_REGISTRATION_CODE is used to register the device with your remoteit account.
```
CONTAINER_NAME=remoteit-agent R3_REGISTRATION_CODE=<your_reg_code> docker-compose up -d
```
or
```
➤ cat .env
CONTAINER_NAME=remoteit-agent
R3_REGISTRATION_CODE=<your_reg_code>

docker-compose up -d
```
You can also create multiple .env files with different container names and registration codes for testing and then pass the .env file on the docker-compose command line:

```
docker-compose --env-file=.env_remoteit_2 up -d
```

The first time you run this it should also create a ./r3configs/remoteit-agent folder which will be mapped to the /etc/remoteit folder inside the container.  After the container gets registered as a device in your remoteit account there should be a ./r3configs/remoteit-agent/config.json file.  Do not delete this folder otherwise everytime you bring down the docker-compose environment and bring it back up it will re-register as a new device.

To bring down the docker-compose environment you can run:
```
docker-compose down
```
