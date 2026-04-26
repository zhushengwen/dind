docker build --secret id=my_secret_var,src=arg.txt --build-arg LANG_TYPE=node -f Dockerfile.multi -t dind:node . 2>&1
docker run --rm -it dind:node bash