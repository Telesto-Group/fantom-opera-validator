# fantom-opera-validator

## 1. Setup an AWS node
- [current EC2 recommendations](https://docs.fantom.foundation/staking/how-to-run-a-validator-node#validator-parameters)

## 2. Create a non-root user and install opera
 - from your AWS ec2 node, as the default user, run:
 - be sure to give a user name in place of &lt;username>
```
curl https://raw.githubusercontent.com/mhetzel/fantom-opera-validator/main/setupValidator.sh | bash -s <username>
```
## 3. Sync node
- Log in to the node as the new non-root user and run:
```
docker-compose up -d sync
```
## 4. Create a validator wallet and validator:
- enter docker:
```
docker-compose run validator /bin/bash
```
- run [commands from the docs](https://docs.fantom.foundation/staking/how-to-run-a-validator-node#create-a-validator-wallet)
- save your password to /home/fantom/passdir/password
- exit docker:
```
exit
```

## 5. [Start in validator mode](https://docs.fantom.foundation/staking/how-to-run-a-validator-node#run-your-fantom-validator-node)
```
export VALIDATOR_ID=<validatorID>
export KEY=<publicKey>
docker-compose stop sync
docker-compose up -d validator
```

## Notes
[Run commands in the background](https://www.computerhope.com/unix/unohup.htm)

checking docker logs:
docker ps -a
docker logs --tail 100 <container ID> or docker logs --follow <container ID>
