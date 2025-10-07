


### Docker

The latest image is available on DockerHub at [`listmonk/listmonk:latest`](https://hub.docker.com/r/listmonk/listmonk/tags?page=1&ordering=last_updated&name=latest).
Download and use the sample [docker-compose.yml](https://github.com/knadh/listmonk/blob/master/docker-compose.yml).


```shell
curl -LO https://github.com/muhammadmaqbool-dot/twosteps/blob/main/docker-compose.yml


docker compose up -d
```
Visit `http://localhost:9000`


First Set STMP ( GMAIL ) to start a campaign:
Create an App Password in Gmail 
***NOTE***  I've already created one which for gabriella.sugarman@twosteps.ai and i've added in config.toml.sample but you can create another one by following the steps below:
Gmail no longer allows direct login with your account password for SMTP. You must use an App Password.
Go to Google Account Security
Enable 2-Step Verification (if not already enabled).
Click App passwords.
Select:
App → "Mail"
Device → "Other (Custom name)" → Enter “TwoSteps”
Click Generate and copy the 16-character app password.

2.Configure SMTP:

In the Listmonk dashboard, go to
Settings → SMTP Servers.

Click on SMTP Server.

Select gmail

Fill out the form as follows:

Field	Value
Name	Gmail
Host	smtp.gmail.com
Port	587/465
Username	your Gmail address (e.g. you@gmail.com)
Password	your 16-character App Password


and also you can test connection on same STMPT page 
test connection button will be on the bottom right.

 



## License
listmonk is licensed under the AGPL v3 license.




