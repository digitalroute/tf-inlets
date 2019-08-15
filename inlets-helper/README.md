# Connecting to inlets as a client
## Using locally installed client
```
# Tunnel any.foo.com to your minikube
inlets client --remote wss://foo.com --upstream="any.foo.com=http://$(minikube ip):80" --token XYXY
```
## Using the helper docker image
The docker image adds a helper command. By default, the helper docker image should work just as the original inlets docker image. I.e. it will accept the same arguments as the locally installed client described above, and can even run in server mode. But when the helper command is used, it will default to running in client mode against a default remote.
```
# tunnel any.foo.coom to your minikube
# to use your default remote:
docker run -ti <image> helper --upstream="any.foo.com=http://$(minikube ip):80" --token XYXY # Note 'helper' argument to trigger default behavior

# to override the default remote:
docker run -ti <image> --upstream="any.foo.com=http://$(minikube ip):80" --token XYXY --remote wss://foo.com
```

# Integration with secrets
The docker image adds support for injecting the token as an environment variable, `INL_TOKEN`. This is currently there to allow injecting an AWS KMS secret value.

# Building the helper image
```
# Building
make DOCKER_ARGS='--build-arg "INL_REMOTE_URI=wss://foo.com"' build

# Tag latest and push
make DOCKER_ARGS='--build-arg "INL_REMOTE_URI=wss://foo.com"' push
```
